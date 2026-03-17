test_that("estimate_sigma_equivalent returns a valid amd_sigma object", {
  set.seed(1)
  X <- matrix(rnorm(300), ncol = 6)

  res <- estimate_sigma_equivalent(
    real_data = X,
    its = 3,
    nin = 2,
    nsp = 4,
    sigmas = c(0.5, 1, 2),
    quiet = TRUE,
    make_plot = FALSE,
    return_plot = FALSE
  )

  expect_s3_class(res, "sigma_equivalent")   # ← CORREGIDO
  expect_true(is.numeric(res$amd_real_peak))
  expect_true(is.numeric(res$sigma_equivalent))
  expect_true(is.data.frame(res$table_sigma_amd))
  expect_equal(nrow(res$table_sigma_amd), 3)
})
