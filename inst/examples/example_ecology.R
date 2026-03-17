
## ============================================================
## Example 1: Ecological configurations
##
## This example illustrates the full AMDconfigurations workflow
## using a real ecological dataset. The first objective is the
## same as in the transcriptomic example: to determine whether
## samples concentrate in a limited number of discrete
## configurations in trophic space.
##
## The second objective differs from the transcriptomic example.
## Here we evaluate whether external control parameters (climate)
## can predict the AMD configurations. This mirrors the framework
## used in Mendoza & Araújo (2022), where trophic structures of
## terrestrial communities were shown to be strongly constrained
## by climate.
## ============================================================

library(AMDconfigurations)
library(ggplot2)
library(randomForest)
library(irr)

# Clean workspace, seed, and data
rm(list = ls(all = TRUE))
set.seed(7)

# ------------------------------------------------------------
# Load ecological dataset
# ------------------------------------------------------------
data(Fulldata)

Trophdata <- Fulldata[, c("IFd","GIn","HIn","IFr","Crn","Pln","Frg","Nct","Grn")]
Climdata  <- Fulldata[, grep("^BIO", names(Fulldata))]

real_data <- as.matrix(Trophdata)

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
  main = "AMD curve of the ecological dataset"
)
abline(v = c_opt, col = "red", lty = 2)

# ------------------------------------------------------------
# B) σ‑Equivalent calibration
# ------------------------------------------------------------

sigma_max <- 15
sigmas <- seq(1, sigma_max, by = 1)

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
# C) Climatic control of AMD configurations
#
# In this ecological example, the second objective is to test
# whether external control parameters (climate) can predict the
# AMD configurations. This contrasts with the transcriptomic
# example, where the goal is to identify internal state variables.
#
# We use a spatial block cross‑validation: each protected area
# acts as an independent block. This provides a stringent test of
# climatic predictability under spatial independence.
# ------------------------------------------------------------

# One representative cell per protected area
rep_idx <- tapply(1:nrow(Fulldata), Fulldata$NAME, function(i) i[1])
rep_idx <- unlist(rep_idx)

clim_rep <- Climdata[rep_idx, ]
resp_rep <- factor(cluster_labels[rep_idx])
blocks   <- Fulldata$NAME[rep_idx]
unique_blocks <- unique(blocks)

# Number of test blocks
n_test_blocks <- 200
set.seed(123)
test_blocks <- sample(unique_blocks, n_test_blocks)

pred_all <- rep(NA, length(resp_rep))

for (b in test_blocks) {

  cat("  Block:", b, "\n")

  train_idx <- which(blocks != b)
  test_idx  <- which(blocks == b)

  rf_model <- randomForest(
    x     = clim_rep[train_idx, ],
    y     = resp_rep[train_idx],
    ntree = 200
  )

  pred_block <- predict(rf_model, clim_rep[test_idx, ])
  pred_all[test_idx] <- as.numeric(pred_block)
}

valid_idx <- which(!is.na(pred_all))

kappa_result <- kappa2(cbind(as.numeric(resp_rep[valid_idx]),
                             pred_all[valid_idx]))

cat("\nGlobal Kappa (", n_test_blocks,
    " protected‑area blocks):\n", sep = "")
print(kappa_result)

# ------------------------------------------------------------
# Interpretation
#
# High predictive accuracy under spatial block validation
# indicates that climatic variables contain enough information to
# recover the AMD configurations. This supports the hypothesis
# that climate acts as a control parameter governing the
# large‑scale organisation of ecological communities.
#
# This contrasts with the transcriptomic example, where the
# second objective is not to identify external control parameters
# but to identify internal state variables (transcripts) that
# contribute to configuration separation.
# ------------------------------------------------------------
