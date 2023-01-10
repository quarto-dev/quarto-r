test_that("quarto_version returns a numeric version", {
  skip_if(is.null(quarto_path()))
  expect_s3_class(quarto_version(), "numeric_version")
})
