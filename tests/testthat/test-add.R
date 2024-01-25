test_that("Installing an extension", {
  skip_if_no_quarto()
  skip_if_offline("github.com")
  qmd <- local_qmd_file(c("content"))
  withr::local_dir(dirname(qmd))
  expect_error(quarto_add_extension("quarto-ext/fontawesome"), "explicit approval")
  quarto_add_extension("quarto-ext/fontawesome", no_prompt = TRUE, quiet = TRUE)
  expect_true(dir.exists("_extensions/quarto-ext/fontawesome"))
})
