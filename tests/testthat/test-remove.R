test_that("Removing an extension", {
  skip_if_no_quarto()
  skip_if_offline("github.com")
  qmd <- local_qmd_file(c("content"))
  withr::local_dir(dirname(qmd))
  expect_snapshot(expect_false(quarto_remove_extension(
    "quarto-ext/fontawesome",
    no_prompt = TRUE
  )))
  quarto_add_extension("quarto-ext/fontawesome", no_prompt = TRUE, quiet = TRUE)
  expect_true(dir.exists("_extensions/quarto-ext/fontawesome"))
  expect_snapshot(expect_true(quarto_remove_extension(
    "quarto-ext/fontawesome",
    no_prompt = TRUE
  )))
  expect_false(dir.exists("_extensions"))
})
