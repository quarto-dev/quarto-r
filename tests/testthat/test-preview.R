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
