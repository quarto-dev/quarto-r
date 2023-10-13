test_that("quarto_version returns a numeric version", {
  skip_if_no_quarto()
  expect_s3_class(quarto_version(), "numeric_version")
})
