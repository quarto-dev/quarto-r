test_that("An error is reported when Quarto is not installed", {
  skip_if_quarto()
  expect_error(quarto_render("test.Rmd"))
})


test_that("R Markdown documents can be rendered", {
  skip_if_no_quarto()
  quarto_render("test.Rmd", quiet = TRUE)
  expect_true(file.exists("test.html"))
  unlink("test.html")
})

test_that("metadata argument works in quarto_render", {
  skip_if_no_quarto()
  qmd <- local_qmd_file(c("content"))
  # metadata
  expect_snapshot_qmd_output(name = "metadata", input = qmd, output_format = "native", metadata = list(title = "test"))
})

test_that("metadata-file argument works in quarto_render", {
  skip_if_no_quarto()
  skip_if_not_installed("withr")
  qmd <- local_qmd_file(c("content"))
  yaml <- withr::local_tempfile(fileext = ".yml")
  write_yaml(list(title = "test"), yaml)
  expect_snapshot_qmd_output(
    name = "metadata-file",
    input = qmd,
    output_format = "native",
    metadata_file = yaml
  )
})

test_that("metadata-file and metadata are merged in quarto_render", {
  skip_if_no_quarto()
  skip_if_not_installed("withr")
  qmd <- local_qmd_file(c("content"))
  yaml <- withr::local_tempfile(fileext = ".yml")
  write_yaml(list(title = "test"), yaml)
  expect_snapshot_qmd_output(
    name = "metadata-merged",
    input = qmd,
    output_format = "native",
    metadata_file = yaml, metadata = list(title = "test2")
  )
})
