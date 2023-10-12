test_that("R Markdown documents can be inspected", {
  skip_if_no_quarto()
  metadata <- quarto_inspect("test.Rmd")
  expect_type(metadata$formats, "list")
})

test_that("Quarto projects can be inspected", {
  skip_if_no_quarto()
  metadata <- quarto_inspect("project")
  expect_type(metadata$config, "list")
})
