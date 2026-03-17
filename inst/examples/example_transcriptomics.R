## ============================================================
## Example 2: Transcriptomic configurations
##
## This example mirrors the ecological case, but on a
## high‑dimensional transcriptomic dataset. The first objective
## is the same: to determine whether samples concentrate in a
## limited number of discrete configurations in expression space.
##
## The second objective differs: here we identify the internal
## state variables (transcripts) most strongly associated with
## configuration separation, using XGBoost and partial dependence
## profiles (PDPs).
##
## NOTE:
## The dataset used here is Transcdata_small, a reduced version
## (1000 variables) included in the package for fast examples.
## The full dataset (~58,000 variables, including metadata such
## as ID and type) is available at Zenodo:
## https://doi.org/10.5281/zenodo.18604443
##
## ============================================================

library(AMDconfigurations)
library(ggplot2)
library(xgboost)
library(DALEX)

# Clean workspace, seed, and data
rm(list = ls(all = TRUE))
set.seed(7)

# ------------------------------------------------------------
# Load reduced transcriptomic dataset
# ------------------------------------------------------------
data(Transcdata_small)

# The reduced dataset contains only expression variables.
# No metadata columns (ID, type) are included here.
expr <- Transcdata_small

# ------------------------------------------------------------
# Optional variance filtering
#
# Transcriptomic datasets often contain tens of thousands of
# variables. Variance filtering is an optional acceleration step.
# It keeps the transcripts with the largest across‑sample variance.
#
# IMPORTANT:
# - This step is optional.
# - In some datasets, discriminating variables may have low variance.
# - Users should test sensitivity to p.
# ------------------------------------------------------------

p <- 200   # number of variables to keep

vars <- apply(expr, 2, var, na.rm = TRUE)
vars_sorted <- sort(vars, decreasing = TRUE)

p <- min(p, ncol(expr))
top_genes <- names(vars_sorted)[1:p]

expr <- expr[, top_genes, drop = FALSE]
real_data <- as.matrix(expr)

# ------------------------------------------------------------
# A) AMD analysis: detect discrete configurations
# ------------------------------------------------------------

its      <- 50
nin      <- 2
nsp      <- 19
iter_max <- 20

cat("Computing real AMD curve...\n")

res_AMD <- compute_amd_curve(
  data     = real_data,
  its      = its,
  nin      = nin,
  nsp      = nsp,
  iter_max = iter_max,
  verbose  = TRUE
)

c_opt <- res_AMD$c_opt
cat("Detected c_opt:", c_opt, "\n")

plot(
  x = as.numeric(names(res_AMD$max)),
  y = res_AMD$max,
  type = "b", pch = 16,
  xlab = "Number of configurations (c)",
  ylab = "AMD",
  main = "AMD curve of the transcriptomic dataset"
)
abline(v = c_opt, col = "red", lty = 2)

# ------------------------------------------------------------
# B) σ‑Equivalent calibration
# ------------------------------------------------------------

sigma_max <- 20
sigmas <- seq(1, sigma_max, by = 2)

set.seed(123)

res_sigma <- estimate_sigma_equivalent(
  real_data   = real_data,
  its         = its,
  nin         = nin,
  nsp         = nsp,
  c_opt       = c_opt,
  sigmas      = sigmas,
  iter_max    = iter_max,
  make_plot   = TRUE,
  return_plot = TRUE,
  quiet       = FALSE
)

cat("Real AMD peak: ", res_sigma$amd_real_peak, "\n")
cat("Interpretation: real compactness is equivalent to ",
    round(res_sigma$sigma_eq),
    "% of the hypercube side length.\n", sep = "")

# ------------------------------------------------------------
# Assign samples to AMD configurations
# ------------------------------------------------------------

assign_res <- assign_configurations(
  data     = real_data,
  c        = c_opt,
  its      = its,
  iter_max = iter_max,
  verbose  = TRUE
)

cluster_labels <- assign_res$cluster
real_data_with_labels <- data.frame(real_data, cluster = cluster_labels)

# ------------------------------------------------------------
# C) Identifying state variables with XGBoost
#
# Unlike the ecological example (RF + climate), here the goal is
# to identify the internal variables (transcripts) most strongly
# associated with configuration separation.
#
# We use:
# - XGBoost with decision stumps (max_depth = 1)
# - Gain importance
# - Robustness across 50 refits with different seeds
# - PDPs for the most stable transcripts
# ------------------------------------------------------------

# Prepare labels (0..K-1)
y <- as.integer(factor(cluster_labels)) - 1
K <- length(unique(y))

# Design matrix
X <- real_data
dtrain <- xgb.DMatrix(data = X, label = y)

# Conservative XGBoost parameters
params_rank <- list(
  booster = "gbtree",
  objective = "multi:softprob",
  num_class = K,
  eta = 0.05,
  max_depth = 1,
  subsample = 0.8,
  colsample_bytree = 0.8,
  min_child_weight = 5,
  gamma = 0,
  lambda = 1,
  alpha = 0
)

# ------------------------------------------------------------
# 1) Main model: Gain importance
# ------------------------------------------------------------
set.seed(7)
fit_xgb <- xgb.train(
  params  = params_rank,
  data    = dtrain,
  nrounds = 300,
  verbose = 0
)

imp <- xgb.importance(model = fit_xgb)

# Top 20 for display
imp_top <- imp[1:20, ]

ggplot(imp_top, aes(x = reorder(Feature, Gain), y = Gain)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    x = "",
    y = "Gain importance",
    title = "Top transcripts by Gain importance"
  ) +
  theme_bw() +
  theme(
    panel.border = element_rect(colour = "black", fill = NA),
    panel.grid.minor = element_blank()
  )

# ------------------------------------------------------------
# 2) Robustness across 50 refits
# ------------------------------------------------------------
seeds_rank <- 1:50
topN <- 5
features <- colnames(X)

mean_gain <- setNames(rep(0, length(features)), features)
freq_topN <- setNames(rep(0, length(features)), features)

for (s in seeds_rank) {
  set.seed(s)

  fit_tmp <- xgb.train(
    params  = params_rank,
    data    = dtrain,
    nrounds = 300,
    verbose = 0
  )

  imp_tmp <- xgb.importance(model = fit_tmp)

  g <- setNames(rep(0, length(features)), features)
  if (nrow(imp_tmp) > 0) g[imp_tmp$Feature] <- imp_tmp$Gain

  mean_gain <- mean_gain + g

  rk <- rank(-g, ties.method = "first")
  freq_topN <- freq_topN + as.integer(rk <= topN)
}

mean_gain <- mean_gain / length(seeds_rank)

consensus <- data.frame(
  Feature   = features,
  MeanGain  = as.numeric(mean_gain),
  freq_topN = as.integer(freq_topN)
)

consensus <- consensus[order(consensus$freq_topN, consensus$MeanGain, decreasing = TRUE), ]

# ------------------------------------------------------------
# 3) Plot robustness: freq_topN vs MeanGain
# ------------------------------------------------------------
thr_freq <- round(0.8 * length(seeds_rank))  # highly stable threshold
lab_idx <- consensus$freq_topN >= thr_freq & consensus$MeanGain > 0

ggplot(consensus, aes(x = freq_topN, y = MeanGain)) +
  geom_point(alpha = 0.8, size = 2) +
  geom_text(
    data = consensus[lab_idx, ],
    aes(label = Feature),
    vjust = -0.5, size = 3, check_overlap = TRUE
  ) +
  scale_x_continuous(breaks = seq(0, length(seeds_rank), by = 10)) +
  labs(
    x = paste0("Frequency in top-", topN, " (out of ", length(seeds_rank), " runs)"),
    y = "Mean Gain",
    title = "Robustness of transcript importance across 50 refits"
  ) +
  theme_bw() +
  theme(
    panel.border = element_rect(colour = "black", fill = NA),
    panel.grid.minor = element_blank()
  )

# ------------------------------------------------------------
# 4) Select top stable transcripts for PDPs
# ------------------------------------------------------------
top_features <- head(consensus$Feature, 5)

# ------------------------------------------------------------
# 5) PDPs for the top transcript
# ------------------------------------------------------------
predict_soft <- function(model, newdata) {
  p <- predict(model, as.matrix(newdata))
  matrix(p, ncol = K, byrow = TRUE)
}

expl <- DALEX::explain(
  model = fit_xgb,
  data  = as.data.frame(X),
  y     = y,
  predict_function = predict_soft,
  verbose = FALSE
)

pdp_top1 <- model_profile(
  explainer = expl,
  variables = top_features[1],
  type = "partial"
)

plot(pdp_top1)
