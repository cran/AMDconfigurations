#' Plot the AMD curve
#'
#' This function plots the Average Membership Degree (AMD) curve from an object
#' returned by \code{compute_amd_curve()}. It visualises either the mean AMD
#' values or the maximum AMD values across iterations, and marks the optimal
#' number of configurations <i>c</i><sub>opt</sub>.
#'
#' @param amd_object A list returned by \code{compute_amd_curve()}.
#' @param type Character string indicating which AMD curve to plot:
#'   \itemize{
#'     \item \code{"mean"} (default): plot mean AMD across iterations.
#'     \item \code{"max"}: plot maximum AMD across iterations.
#'   }
#' @param open_device Logical; if \code{TRUE}, open a new graphics device.
#' @param ... Additional graphical parameters passed to \code{plot()}.
#'
#' @return Invisibly returns \code{NULL}. The function is called for its side
#'   effect of producing a plot.
#'
#' @examples
#' \donttest{
#' X <- matrix(rnorm(2000), ncol = 10)
#' res <- compute_amd_curve(X, its = 10, nin = 2, nsp = 8)
#' plot_AMD(res)
#' plot_AMD(res, type = "max")
#' }
#'
#' @export
plot_AMD <- function(amd_object,
                     type = c("mean", "max"),
                     open_device = TRUE,
                     ...) {

  # --- Input checks ----------------------------------------------------------
  if (!is.list(amd_object)) {
    stop("amd_object must be a list returned by compute_amd_curve().")
  }
  if (!("mean" %in% names(amd_object)) ||
      !("max"  %in% names(amd_object)) ||
      !("c_opt" %in% names(amd_object))) {
    stop("amd_object does not contain required AMD components.")
  }

  type <- match.arg(type)

  # Extract AMD values
  ks <- as.numeric(names(amd_object$mean))
  if (anyNA(ks)) ks <- seq_along(amd_object$mean)

  y <- switch(type,
              mean = amd_object$mean,
              max  = amd_object$max)

  # --- Plot ------------------------------------------------------------------
  if (open_device) {
  }

  plot(ks, y,
       type = "b", pch = 16,
       xlab = "Number of configurations (c)",
       ylab = sprintf("AMD (%s)", type),
       ...)

  abline(v = amd_object$c_opt, col = "blue", lty = 3, lwd = 2)

  invisible(NULL)
}

#' Plot method for AMD curve objects
#'
#' This method provides a convenient interface to plot AMD curves returned by
#' \code{compute_amd_curve()}. It forwards the call to \code{plot_AMD()}, allowing
#' users to simply call \code{plot(res)}.
#'
#' @param x An object of class \code{"amd_curve"}.
#' @param type Character string indicating which AMD curve to plot:
#'   \code{"mean"} (default) or \code{"max"}.
#' @param open_device Logical; if \code{TRUE}, open a new graphics device.
#' @param ... Additional arguments passed to \code{plot_AMD()}.
#'
#' @return Invisibly returns \code{NULL}.
#'
#' @export
plot.amd_curve <- function(x,
                           type = c("mean", "max"),
                           open_device = TRUE,
                           ...) {
  plot_AMD(
    amd_object = x,
    type = type,
    open_device = open_device,
    ...
  )
}
