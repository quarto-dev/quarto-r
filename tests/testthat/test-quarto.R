test_that("quarto_version returns a numeric version", {
  skip_if_no_quarto()
  expect_s3_class(quarto_version(), "numeric_version")
})

test_that("quarto_run gives guidance in error", {
  skip_if_no_quarto()
  expect_snapshot(quarto_run(c("rend", "--quiet")), error = TRUE)
})
