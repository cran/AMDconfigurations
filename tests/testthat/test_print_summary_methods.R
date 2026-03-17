test_that("print and summary methods run without error", {
  set.seed(1)
  X <- matrix(rnorm(200), ncol = 5)

  res <- compute_amd_curve(
    data = X,
    its = 3,
    nin = 2,
    nsp = 4,
    verbose = FALSE
  )

  expect_output(print(res))
  expect_output(summary(res))

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

  expect_output(print(res_sigma))
  expect_output(summary(res_sigma))
})
