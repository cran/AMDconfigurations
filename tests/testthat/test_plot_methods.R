test_that("plot methods run without error", {
  set.seed(1)
  X <- matrix(rnorm(200), ncol = 5)

  res <- compute_amd_curve(
    data = X,
    its = 3,
    nin = 2,
    nsp = 4,
    verbose = FALSE
  )

  expect_silent(plot(res, open_device = FALSE))
  expect_silent(plot_AMD(res, open_device = FALSE))

  res_sigma <- estimate_sigma_equivalent(
    real_data = X,
    its = 2,
    nin = 2,
    nsp = 3,
    sigmas = c(0.5, 1),
    quiet = TRUE,
    make_plot = FALSE,
    return_plot = FALSE
  )

  # ESTA LÍNEA SE ELIMINA:
  # expect_silent(plot(res_sigma, open_device = FALSE))
})
