test_that("quarto_preview default functionality", {
  skip_if_no_quarto()
  skip_on_cran()

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
  skip_if_no_quarto()
  skip_on_cran()

  tmp_dir <- withr::local_tempdir()
  withr::local_dir(tmp_dir)
  xfun::write_utf8(c("---", "title: Test", "---", "", "# Hello"), "test.qmd")

  expect_no_error({
    url <- withr::with_dir(tmp_dir, {
      quarto_preview("test.qmd", port = 8888, browse = FALSE, quiet = TRUE)
    })
  })

  # Always clean up
  withr::defer(quarto_preview_stop())

  if (exists("url")) {
    expect_true(grepl("^https?://", url))
    expect_true(grepl(":8888", url))
  }
})
