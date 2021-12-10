test_that("quarto_version returns a numeric version", {
  expect_s3_class(quarto_version(), "numeric_version")
})
