test_that("quarto_version returns a numeric version", {
  skip_if_no_quarto()
  expect_s3_class(quarto_version(), "numeric_version")
})

test_that("quarto_run gives guidance in error", {
  skip_if_no_quarto()
  expect_snapshot(
    error = TRUE,
    quarto_run(c("rend", "--quiet")),
    transform = transform_quarto_cli_in_output()
    )
})
