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
  write_yaml(list(title = "test", other = "thing"), yaml)
  expect_snapshot_qmd_output(
    name = "metadata-merged",
    input = qmd,
    output_format = "native",
    metadata_file = yaml,
    metadata = list(title = "test2", any = "one")
  )
})

test_that("quarto_args in quarto_render", {
  skip_if_no_quarto()
  withr::local_envvar(list(QUARTO_R_QUIET = NA))
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

test_that("`quarto_render(as_job = TRUE)` is wrappable", {
  # this tests background jobs, a feature only available in interactive RStudio IDE sesssions
  # This is here for manual testing. This test should not run otherwise.
  skip_on_cran()
  skip_if_no_quarto()
  skip_if_not(
    rstudioapi::isAvailable() &&
      rstudioapi::hasFun("runScriptJob") &&
      in_rstudio(),
    message = "quarto_render(as_job = TRUE) is only available in RStudio IDE sessions with job support."
  )
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
  expect_message(
    wrapper(basename(qmd), output, "native"),
    "Rendering project as background job"
  )
  # wait for background job to finish (10s should be conservative enough)
  Sys.sleep(10)
  expect_true(file.exists(output))
})

test_that("quarto_render allows to pass output-file meta", {
  skip_if_no_quarto()
  qmd <- local_qmd_file(c(
    "---",
    "title: Example title",
    "format:",
    "    html:",
    "       toc: true",
    "    docx:",
    "        toc: true",
    "---",
    ""
  ))
  quarto_render(
    qmd,
    output_file = "final_report",
    output_format = "all",
    quiet = TRUE
  )
  withr::local_dir(dirname(qmd))
  expect_true(file.exists("final_report.html"))
  expect_true(file.exists("final_report.docx"))
})


test_that("{ } are escaped correctly in abort message", {
  skip_if_no_quarto()
  proj <- test_path("resources", "cli_error")
  withr::local_dir(proj)
  keep_files <- list.files(".", all.files = TRUE)
  withr::defer({
    unlink(
      setdiff(list.files(".", all.files = TRUE), keep_files),
      recursive = TRUE,
      force = TRUE
    )
  })
  withr::local_options(quarto.tests.hide_echo = TRUE)
  expect_snapshot(
    error = TRUE,
    quarto_render(
      "pdf-error.qmd",
      quiet = FALSE,
      quarto_args = c("--log", "test.log")
    )
  )
})
