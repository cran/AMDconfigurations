## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message = FALSE
)
library(AMDconfigurations)

## ----curve--------------------------------------------------------------------
set.seed(8301)
X <- rbind(
  matrix(rnorm(90, mean = 0, sd = 0.7), ncol = 3),
  matrix(rnorm(90, mean = 4, sd = 0.7), ncol = 3),
  matrix(rnorm(90, mean = 8, sd = 0.7), ncol = 3)
)

candidate_c <- 2:5
starts <- 3L
seed_matrix <- outer(
  seq_len(starts),
  candidate_c,
  function(start, c) 100000L + 1000L * c + start
)
colnames(seed_matrix) <- as.character(candidate_c)

amd_curve <- compute_amd_curve(
  X,
  its = starts,
  nin = min(candidate_c),
  nsp = max(candidate_c),
  seeds = seed_matrix,
  iter_max = 1000,
  verbose = FALSE
)

data.frame(
  c = candidate_c,
  AMD = unname(amd_curve$curve),
  converged_starts = colSums(amd_curve$converged)
)

abs(amd_curve$curve[["3"]] - amd_curve$curve[["4"]])

## ----curve-plot, fig.width=6, fig.height=4------------------------------------
plot(amd_curve, open_device = FALSE)

## ----assignment---------------------------------------------------------------
chosen_c <- 3L
assignment <- assign_configurations(amd_curve, c = chosen_c)

identical(
  assignment$membership,
  amd_curve$selected_fits[[as.character(chosen_c)]]$membership
)

## ----stored-diagnostics-------------------------------------------------------
diagnostics <- diagnose_amd(amd_curve)
diagnostics$candidates[, c("c", "amd", "mean_winning_membership")]
diagnostics$transitions

## ----optional-reader, eval=FALSE----------------------------------------------
# reader <- load_amd_predictor(bundle_path, sha256 = bundle_sha256)
# result <- predict_amd(X, reader, seed = 123, verbose = FALSE)
# plot(result)
# result$proposed_k
# result$reliability

## ----manifest-----------------------------------------------------------------
manifest <- amd_reproducibility_manifest()
identical(amd_curve$manifest_id, manifest$manifest_id)
manifest[c("r_version", "amdconfigurations_version", "e1071_version", "rng_kind")]

