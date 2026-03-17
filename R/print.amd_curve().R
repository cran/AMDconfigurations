#' Print method for AMD curve objects
#'
#' Provides a concise summary of an AMD curve object returned by
#' \code{compute_amd_curve()}. Displays the optimal number of configurations
#' <i>c</i><sub>opt</sub>, the AMD peak, and the evaluated range of \code{k}.
#'
#' @param x An object of class \code{"amd_curve"}.
#' @param ... Unused.
#'
#' @return Invisibly returns \code{x}.
#'
#' @export
print.amd_curve <- function(x, ...) {

  if (!inherits(x, "amd_curve")) {
    stop("Object is not of class 'amd_curve'.")
  }

  ks <- as.numeric(names(x$mean))
  if (anyNA(ks)) ks <- seq_along(x$mean)

  amd_peak <- max(x$max, na.rm = TRUE)

  cat("AMD curve object\n")
  cat("  c_opt: ", x$k_opt, "\n", sep = "")
  cat("  AMD peak (max): ", sprintf("%.4f", amd_peak), "\n", sep = "")
  cat("  Range of k: ", min(ks), " - ", max(ks), "\n", sep = "")

  invisible(x)
}
