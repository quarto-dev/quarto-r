test_that("has_parameters() works with knitr engine", {
  skip_if_no_quarto()

  # Create a .qmd file with params in metadata
  qmd_with_params <- local_qmd_file(
    "---",
    "title: Test Document",
    "params:",
    "  name: John",
    "---",
    "",
    "# Test Document",
    "",
    "This is a test document with parameters.",
    "```{r}",
    "params$name",
    "```"
  )

  # Create a .qmd file without params
  qmd_no_params <- local_qmd_file(
    "---",
    "title: Test Document",
    "---",
    "",
    "# Test Document",
    "",
    "This is a test document without parameters."
  )

  expect_true(has_parameters(qmd_with_params))
  expect_false(has_parameters(qmd_no_params))
})

test_that("has_parameters() works with Jupyter engine", {
  skip_if_no_quarto()

  # Test with notebook that has parameters cell
  expect_true(has_parameters(resources_path("test-with-parameters.ipynb")))

  # Test with notebook that doesn't have parameters
  expect_false(has_parameters(resources_path("test-no-parameters.ipynb")))
})

test_that("has_parameters() handles non-existent files", {
  expect_error(
    has_parameters("non-existent-file.qmd"),
    class = "rlang_error"
  )
})

test_that("has_parameters() works with existing test files", {
  skip_if_no_quarto()

  # Test with existing test files that don't have parameters
  expect_false(has_parameters(test_path("test.qmd")))
  expect_false(has_parameters(test_path("test.ipynb")))
})
