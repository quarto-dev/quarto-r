test_that("Installing an extension", {
  skip_if_no_quarto()
  skip_if_offline("github.com")
  dir <- withr::local_tempdir()
  withr::local_dir(dir)
  expect_error(quarto_use_template("quarto-journals/jss"), "explicit approval")
  quarto_use_template("quarto-journals/jss", no_prompt = TRUE)
  expect_true(dir.exists("_extensions/quarto-journals/jss"))
  expect_length(list.files(pattern = "[.]qmd$"), 1)
})

test_that("quarto_use_binder errors < 1.5", {
  skip_if_quarto(ver = "1.5")
  expect_snapshot(
    error = TRUE,
    quarto_use_binder(),
    transform = transform_quarto_cli_in_output(full_path = TRUE),
    variant = "quarto-before-1.5"
  )
})

test_that("quarto_use_binder works", {
  skip_on_cran()
  skip_if_no_quarto(ver = "1.5")

  project <- local_quarto_project(
    c("---",
      "title: Histogram",
      "---",
      "",
      "```{r}",
      "hist(rnorm(100))",
      "```")
  )
  withr::local_dir(project)
  expect_snapshot(
    error = TRUE,
    quarto_use_binder(no_prompt = FALSE)
  )
  quarto_use_binder(no_prompt = TRUE)
})
