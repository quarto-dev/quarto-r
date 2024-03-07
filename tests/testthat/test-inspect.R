test_that("Documents can be inspected", {
  skip_if_no_quarto()
  metadata <- quarto_inspect(test_path("test.Rmd"))
  expect_type(metadata$formats, "list")
  metadata <- quarto_inspect(test_path("test.qmd"))
  expect_type(metadata$formats, "list")
  metadata <- quarto_inspect(test_path("test.ipynb"))
  expect_type(metadata$formats, "list")
})

test_that("Quarto projects can be inspected", {
  skip_if_no_quarto()
  metadata <- quarto_inspect(test_path("project"))
  expect_type(metadata$config, "list")
})

test_that("Quarto projects can be inspected with profile", {
  skip_if_no_quarto()
  metadata <- quarto_inspect(test_path("project"), "test")
  expect_type(metadata$config, "list")
  expect_identical(metadata$config$execute$echo, TRUE)
})
