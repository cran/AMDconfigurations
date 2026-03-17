#' Plot method for sigma-equivalent objects
#'
#' Plots the relationship between tested sigma values and the corresponding
#' synthetic AMD peaks, marking the real AMD peak and the estimated
#' sigma-equivalent value \eqn{\sigma_{eq}}.
#'
#' This method is automatically invoked when calling \code{plot(x)} on an
#' object returned by \code{estimate_sigma_equivalent()}.
#'
#' @param x An object of class \code{"amd_sigma"} returned by
#'   \code{estimate_sigma_equivalent()}.
#' @param open_device Logical; if \code{TRUE}, open a new graphics device.
#' @param ... Additional graphical parameters passed to \code{plot()}.
#'
#' @return Invisibly returns \code{NULL}.
#'
#' @export
plot.amd_sigma <- function(x,
                           open_device = TRUE,
                           ...) {

  if (!inherits(x, "amd_sigma")) {
    stop("Object is not of class 'amd_sigma'.")
  }

  tbl <- x$table_sigma_amd

  # Open device if requested
  if (open_device) {
  }

  # Base plot
  plot(tbl$sigma, tbl$AMD_max,
       type = "b", pch = 16,
       xlab = expression(sigma),
       ylab = "Synthetic AMD peak",
       ...)

  # Horizontal line: real AMD peak
  abline(h = x$amd_real_peak, col = "red", lty = 2, lwd = 2)

  # Vertical line: sigma-equivalent
  abline(v = x$sigma_equivalent, col = "blue", lty = 3, lwd = 2)

  invisible(NULL)
}
