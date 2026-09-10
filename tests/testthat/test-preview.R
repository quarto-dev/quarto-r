test_that("quarto_preview_stop stops the preview server", {
  skip_if_no_quarto()
  skip_if_not_installed("callr")
  skip_on_cran()

  tmp_dir <- withr::local_tempdir()
  input <- file.path(tmp_dir, "test.qmd")
  xfun::write_utf8(c("---", "title: Test", "---", "", "# Hello"), input)

  result_file <- file.path(tmp_dir, "result.rds")
  stdout_file <- file.path(tmp_dir, "stdout.log")
  stderr_file <- file.path(tmp_dir, "stderr.log")

  preview_process <- callr::r_bg(
    function(package_path, input, result_file) {
      source_r_dir <- file.path(package_path, "R")
      is_source_tree <-
        file.exists(file.path(package_path, "DESCRIPTION")) &&
        dir.exists(source_r_dir) &&
        length(list.files(source_r_dir, pattern = "\\.[Rr]$")) > 0

      if (is_source_tree) {
        pkgload::load_all(package_path, quiet = TRUE)
      } else {
        loadNamespace("quarto")
      }

      port <- quarto:::find_port()
      quarto::quarto_preview(
        input,
        port = port,
        browse = FALSE,
        quiet = TRUE
      )
      quarto::quarto_preview_stop()
      saveRDS(quarto:::port_active(port), result_file)

      # Keep the parent alive so the test can reliably terminate the full tree.
      repeat {
        Sys.sleep(1)
      }
    },
    args = list(
      package_path = testthat::test_path("..", ".."),
      input = input,
      result_file = result_file
    ),
    stdout = stdout_file,
    stderr = stderr_file,
    supervise = TRUE
  )
  withr::defer({
    if (preview_process$is_alive()) {
      preview_process$kill_tree()
      preview_process$wait(5000)
    }
  })

  deadline <- Sys.time() + 30
  while (
    !file.exists(result_file) &&
      preview_process$is_alive() &&
      Sys.time() < deadline
  ) {
    Sys.sleep(0.1)
  }

  if (!file.exists(result_file)) {
    output <- c(
      readLines(stdout_file, warn = FALSE),
      readLines(stderr_file, warn = FALSE)
    )
    fail(paste(
      c("Preview subprocess did not return a result.", output),
      collapse = "\n"
    ))
    return()
  }

  port_is_active <- readRDS(result_file)
  preview_process$kill_tree()
  preview_process$wait(5000)

  expect_identical(port_is_active, FALSE)
})


test_that("quarto_preview default functionality", {
  skip("quarto-preview test only works interactively")
  skip_if_no_quarto()
  skip_on_cran()
  skip_on_ci()

  tmp_dir <- withr::local_tempdir()
  withr::local_dir(tmp_dir)
  xfun::write_utf8(c("---", "title: Test", "---", "", "# Hello"), "test.qmd")

  expect_no_error({
    url <- withr::with_dir(tmp_dir, {
      quarto_preview("test.qmd", browse = FALSE, quiet = TRUE)
    })
  })

  # Always clean up
  withr::defer(quarto_preview_stop())

  if (exists("url")) {
    expect_true(grepl("^https?://", url))
  }
})

test_that("quarto_preview can change port", {
  skip("quarto-preview test only works interactively")
  skip_if_no_quarto()
  skip_on_cran()
  skip_on_ci()

  tmp_dir <- withr::local_tempdir()
  withr::local_dir(tmp_dir)
  xfun::write_utf8(c("---", "title: Test", "---", "", "# Hello"), "test.qmd")

  known_port <- find_port()
  expect_no_error({
    preview_url <- withr::with_dir(tmp_dir, {
      quarto_preview(
        "test.qmd",
        port = known_port,
        browse = FALSE,
        quiet = TRUE
      )
    })
  })

  # Always clean up
  withr::defer(quarto_preview_stop())

  skip_if(!exists("preview_url", inherits = FALSE))
  skip_if(!is.character(preview_url))
  expect_true(grepl("^https?://", preview_url))
  expect_true(grepl(sprintf(":%s", known_port), preview_url))
})
