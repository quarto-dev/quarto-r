test_that("Listing extensions", {
  # don't try to install extensions on CRAN
  skip_on_cran()
  skip_if_no_quarto()
  skip_if_offline("github.com")
  qmd <- local_qmd_file(c("content"))
  withr::local_dir(dirname(qmd))
  expect_null(quarto_list_extensions())
  quarto_add_extension("quarto-ext/fontawesome", no_prompt = TRUE, quiet = TRUE)
  expect_true(dir.exists("_extensions/quarto-ext/fontawesome"))
  expect_identical(
    quarto_list_extensions()$Id,
    c("quarto-ext/fontawesome")
  )
  quarto_add_extension("quarto-ext/lightbox", no_prompt = TRUE, quiet = TRUE)
  expect_true(dir.exists("_extensions/quarto-ext/lightbox"))
  expect_identical(
    quarto_list_extensions()$Id,
    c("quarto-ext/fontawesome", "quarto-ext/lightbox")
  )
})
