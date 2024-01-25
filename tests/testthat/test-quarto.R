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

test_that("is_using_quarto correctly check directory", {
  qmd <- local_qmd_file(c("content"))
  # Only qmd
  expect_true(is_using_quarto(dirname(qmd)))
  expect_snapshot(is_using_quarto(dirname(qmd), verbose = TRUE))
  # qmd and _quarto.yml
  write_yaml(list(project = list(type = "default")), file = file.path(dirname(qmd), "_quarto.yml"))
  expect_true(is_using_quarto(dirname(qmd)))
  expect_snapshot(is_using_quarto(dirname(qmd), verbose = TRUE))
  # Only _quarto.yml
  unlink(qmd)
  expect_true(is_using_quarto(dirname(qmd)))
  expect_snapshot(is_using_quarto(dirname(qmd), verbose = TRUE))
  # Empty dir
  unlink(file.path(dirname(qmd), "_quarto.yml"))
  expect_false(is_using_quarto(dirname(qmd)))
  expect_snapshot(is_using_quarto(dirname(qmd), verbose = TRUE))
  # Non empty dir
  withr::local_dir(dirname(qmd))
  withr::local_file("test.txt")
})
