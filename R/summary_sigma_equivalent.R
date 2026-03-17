#' Summary method for sigma_equivalent objects
#'
#' @param object An object of class "sigma_equivalent".
#' @param ... Additional arguments (ignored).
#'
#' @return Invisibly returns the object.
#' @export
summary.sigma_equivalent <- function(object, ...) {
  cat("Sigma equivalent summary:\n")
  cat("  AMD real peak:    ", object$amd_real_peak, "\n")
  cat("  Sigma equivalent: ", object$sigma_equivalent, "\n")
  invisible(object)
}
