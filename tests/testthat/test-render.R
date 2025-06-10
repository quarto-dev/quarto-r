test_that("An error is reported when Quarto is not installed", {
  skip_if_quarto()
  expect_error(quarto_render("test.Rmd"))
})


test_that("R Markdown documents can be rendered", {
  skip_if_no_quarto()
  quarto_render(test_path("test.Rmd"), quiet = TRUE)
  expect_true(file.exists("test.html"))
  unlink("test.html")
})

test_that("metadata argument works in quarto_render", {
  skip_if_no_quarto()
  qmd <- local_qmd_file(c("content"))
  # metadata
  expect_snapshot_qmd_output(
    name = "metadata",
    input = qmd,
    output_format = "native",
    metadata = list(title = "test")
  )
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
    metadata_file = yaml,
    metadata = list(title = "test2")
  )
})

test_that("quarto_args in quarto_render", {
  skip_if_no_quarto()
  qmd <- local_qmd_file(c("content"))
  local_quarto_run_echo_cmd()
  withr::local_dir(dirname(qmd))
  file.rename(basename(qmd), "input.qmd")
  local_reproducible_output(width = 1000)
  # metadata
  expect_snapshot(
    quarto_render("input.qmd", quiet = TRUE, quarto_args = c("--to", "native")),
    transform = transform_quarto_cli_in_output(full_path = TRUE)
  )
})

test_that("`quarto_render(as_job = TRUE)` is wrapable", {
  # this tests background jobs, a feature only available in interactive RStudio IDE sesssions
  skip_on_cran()
  skip_if_no_quarto()
  skip_if_not(rstudioapi::isAvailable())
  qmd <- local_qmd_file(c("content"))
  withr::local_dir(dirname(qmd))
  output <- basename(
    withr::local_file(xfun::with_ext(qmd, ".native"))
  )
  wrapper <- function(path, out, format) {
    quarto_render(
      input = path,
      output_file = out,
      output_format = format,
      quiet = TRUE,
      as_job = TRUE
    )
  }
  wrapper(basename(qmd), output, "native")
  # wait for background job to finish (10s should be conservative enough)
  Sys.sleep(10)
  expect_true(file.exists(output))
})
