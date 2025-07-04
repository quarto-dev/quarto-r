test_that("Installing an extension in empty dir", {
  skip_if_no_quarto()
  skip_if_offline("github.com")
  dir <- withr::local_tempdir()
  withr::local_dir(dir)
  expect_error(quarto_use_template("quarto-journals/jss"), "explicit approval")
  quarto_use_template("quarto-journals/jss", no_prompt = TRUE, quiet = TRUE)
  expect_true(dir.exists("_extensions/quarto-journals/jss"))
  expect_length(list.files(pattern = "[.]qmd$"), 1)
})

test_that("Installing an extension in a new empty dir", {
  skip_if_no_quarto()
  skip_if_offline("github.com")
  dir <- withr::local_tempfile()
  dir.create(dir)
  withr::local_dir(dir)
  dir.create("empty-dir")
  quarto_use_template(
    "quarto-journals/jss",
    dir = "empty-dir",
    no_prompt = TRUE,
    quiet = TRUE
  )
  expect_true(dir.exists("empty-dir/_extensions/quarto-journals/jss"))
  expect_length(list.files(path = "empty-dir", pattern = "[.]qmd$"), 1)
  expect_equal(list.files(no.. = TRUE, all.files = TRUE), "empty-dir")
})

test_that("Installing an extension in non empty dir errors", {
  skip_if_no_quarto("1.5.15")
  skip_if_offline("github.com")
  dir <- withr::local_tempdir()
  withr::local_dir(dir)
  file.create("README.md")
  expect_snapshot(
    error = TRUE,
    quarto_use_template("quarto-journals/jss", no_prompt = TRUE, quiet = TRUE),
  )
})
