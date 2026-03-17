#' Print method for sigma-equivalent objects
#'
#' Provides a concise summary of an object returned by
#' \code{estimate_sigma_equivalent()}, including the real AMD peak,
#' the estimated sigma-equivalent value sigma_eq, and the
#' tested sigma range.
#'
#' @param x An object of class \code{"amd_sigma"}.
#' @param ... Unused.
#'
#' @return Invisibly returns \code{x}.
#'
#' @export
print.amd_sigma <- function(x, ...) {

  if (!inherits(x, "amd_sigma")) {
    stop("Object is not of class 'amd_sigma'.")
  }

  tbl <- x$table_sigma_amd

  cat("Sigma-equivalent object\n")
  cat("  Real AMD peak: ", sprintf("%.4f", x$amd_real_peak), "\n", sep = "")
  cat("  Estimated sigma_eq (interpolated): ", sprintf("%.4f", x$sigma_equivalent), "\n", sep = "")
  cat("  Nearest-match sigma: ", sprintf("%.4f", x$sigma_eq), "\n", sep = "")
  cat("  Tested sigma range: ", min(tbl$sigma), " - ", max(tbl$sigma), "\n", sep = "")

  invisible(x)
}
