test_that("Updating an extension", {
  skip_if_no_quarto()
  skip_if_offline("github.com")
  qmd <- local_qmd_file(c("content"))
  withr::local_dir(dirname(qmd))
  expect_error(
    quarto_add_extension("quarto-ext/fontawesome@v0.0.1"),
    "explicit approval"
  )
  quarto_update_extension(
    "quarto-ext/fontawesome",
    no_prompt = TRUE,
    quiet = TRUE
  )
  expect_true(dir.exists("_extensions/quarto-ext/fontawesome"))
  current_version <- yaml::read_yaml(
    "_extensions/quarto-ext/fontawesome/_extension.yml"
  )$version
  expect_false(identical(current_version, "v0.0.1"))
})
