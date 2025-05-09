test_that("Updating an extension", {
  skip_if_no_quarto()
  skip_if_offline("github.com")
  qmd <- local_qmd_file(c("content"))
  withr::local_dir(dirname(qmd))
  quarto_add_extension(
    "quarto-ext/fontawesome@v0.0.1",
    no_prompt = TRUE,
    quiet = TRUE
  )
  expect_equal(quarto_list_extensions()$Version, "0.0.1")
  quarto_update_extension(
    "quarto-ext/fontawesome",
    no_prompt = TRUE,
    quiet = TRUE
  )
  expect_true(dir.exists("_extensions/quarto-ext/fontawesome"))
  expect_true(
    as.numeric_version(current_version <- quarto_list_extensions()$Version) >
      "0.0.1"
  )
  expect_false(identical(current_version, "0.0.1"))
})
