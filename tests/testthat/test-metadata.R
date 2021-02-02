test_that("R Markdown documents can be queried for metadata", {
  skip_if(is.null(quarto_path()))
  metadata <- quarto_metadata("test.Rmd")
  expect_type(metadata, "list")
})

test_that("Quarto projects can be queried for metadata", {
  skip_if(is.null(quarto_path()))
  metadata <- quarto_metadata("project")
  expect_type(metadata$project, "list")
})
