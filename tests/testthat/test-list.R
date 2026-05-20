test_that("Listing extensions", {
  # don't try to install extensions on CRAN
  skip_on_cran()
  skip_if_no_quarto()
  skip_if_offline("github.com")
  qmd <- local_qmd_file(c("content"))
  withr::local_dir(dirname(qmd))
  # TODO: Adapt depending on https://github.com/quarto-dev/quarto-r/issues/301
  # expect_null(quarto_list_extensions())
  default <- quarto_list_extensions()$Id
  quarto_add_extension("quarto-ext/fontawesome", no_prompt = TRUE, quiet = TRUE)
  expect_true(dir.exists("_extensions/quarto-ext/fontawesome"))
  expect_identical(
    setdiff(quarto_list_extensions()$Id, default),
    c("quarto-ext/fontawesome")
  )
  quarto_add_extension("quarto-ext/lightbox", no_prompt = TRUE, quiet = TRUE)
  expect_true(dir.exists("_extensions/quarto-ext/lightbox"))
  expect_identical(
    setdiff(quarto_list_extensions()$Id, default),
    c("quarto-ext/fontawesome", "quarto-ext/lightbox")
  )
})
