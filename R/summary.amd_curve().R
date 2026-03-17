#' Summary method for AMD curve objects
#'
#' Provides a detailed summary of an AMD curve object, including mean and
#' maximum AMD values, the optimal number of configurations, and the evaluated
#' range of \code{k}.
#'
#' @param object An object of class \code{"amd_curve"}.
#' @param ... Unused.
#'
#' @return Invisibly returns \code{object}.
#'
#' @export
summary.amd_curve <- function(object, ...) {

  if (!inherits(object, "amd_curve")) {
    stop("Object is not of class 'amd_curve'.")
  }

  ks <- as.numeric(names(object$mean))
  if (anyNA(ks)) ks <- seq_along(object$mean)

  amd_peak <- max(object$max, na.rm = TRUE)

  cat("Summary of AMD curve\n")
  cat("---------------------\n")
  cat("Optimal number of configurations (c_opt): ", object$k_opt, "\n", sep = "")
  cat("AMD peak (max): ", sprintf("%.4f", amd_peak), "\n", sep = "")
  cat("Range of k evaluated: ", min(ks), " - ", max(ks), "\n\n", sep = "")

  df <- data.frame(
    k    = ks,
    mean = object$mean,
    max  = object$max
  )

  print(df, row.names = FALSE)

  invisible(object)
}
