#' Summary method for sigma-equivalent objects
#'
#' Provides a detailed summary of an object returned by
#' \code{estimate_sigma_equivalent()}, including the real AMD peak,
#' the tested sigma values, the corresponding synthetic AMD peaks,
#' and the estimated sigma-equivalent value \eqn{\sigma_{eq}}.
#'
#' @param object An object of class \code{"amd_sigma"}.
#' @param ... Unused.
#'
#' @return Invisibly returns \code{object}.
#'
#' @export
summary.amd_sigma <- function(object, ...) {

  if (!inherits(object, "amd_sigma")) {
    stop("Object is not of class 'amd_sigma'.")
  }

  tbl <- object$table_sigma_amd

  cat("Summary of sigma-equivalent analysis\n")
  cat("-------------------------------------\n")
  cat("Real AMD peak: ", sprintf("%.4f", object$amd_real_peak), "\n", sep = "")
  cat("Estimated sigma_eq (interpolated): ", sprintf("%.4f", object$sigma_equivalent), "\n", sep = "")
  cat("Nearest-match sigma: ", sprintf("%.4f", object$sigma_eq), "\n", sep = "")
  cat("Extrapolated: ", ifelse(isTRUE(object$extrapolated), "yes", "no"), "\n\n", sep = "")

  cat("Sigma vs synthetic AMD peaks:\n")
  print(tbl, row.names = FALSE)

  invisible(object)
}
