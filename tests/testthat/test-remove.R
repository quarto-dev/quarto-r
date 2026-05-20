test_that("Removing an extension", {
  skip_if_no_quarto()
  skip_if_offline("github.com")
  qmd <- local_qmd_file(c("content"))
  # with expect_snapshot, can't use withr::local_dir()
  wd <- dirname(qmd)
  local_edition(3)
  expect_snapshot(withr::with_dir(
    wd,
    expect_false(quarto_remove_extension(
      "quarto-ext/fontawesome",
      no_prompt = TRUE
    ))
  ))
  withr::with_dir(wd, {
    quarto_add_extension(
      "quarto-ext/fontawesome",
      no_prompt = TRUE,
      quiet = TRUE
    )
    expect_true(dir.exists("_extensions/quarto-ext/fontawesome"))
  })
  expect_snapshot(withr::with_dir(
    wd,
    expect_true(quarto_remove_extension(
      "quarto-ext/fontawesome",
      no_prompt = TRUE
    ))
  ))
  withr::with_dir(wd, expect_false(dir.exists("_extensions")))
})
