test_that("compute_amd_curve returns a valid amd_curve object", {
  set.seed(1)
  X <- matrix(rnorm(200), ncol = 5)

  res <- compute_amd_curve(
    data = X,
    its = 5,
    nin = 2,
    nsp = 4,
    verbose = FALSE
  )

  expect_s3_class(res, "amd_curve")
  expect_true(is.numeric(res$c_opt))
  expect_true(is.numeric(res$mean))
  expect_true(is.numeric(res$max))
  expect_true(is.matrix(res$raw))
  expect_equal(length(res$mean), 3)
  expect_equal(length(res$max), 3)
})
