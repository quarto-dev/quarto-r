test_that("Create a quarto project", {
  skip_if_no_quarto("1.4")
  expect_snapshot(
    error = TRUE,
    quarto_create_project()
  )
  tempdir <- withr::local_tempdir()
  withr::local_dir(tempdir)
  expect_no_error(quarto_create_project(name = "test-project", quiet = TRUE))
  expect_true(dir.exists("test-project"))
})

test_that("Create a quarto project in another directory", {
  skip_if_no_quarto("1.4")
  tempdir <- withr::local_tempdir()
  curr_wd <- getwd()
  expect_no_error(quarto_create_project(name = "test-project", dir = tempdir, quiet = TRUE))
  expect_true(dir.exists(file.path(tempdir, "test-project")))
  expect_identical(curr_wd, getwd())
})

test_that("create project only available for 1.4", {
  skip_if_quarto("1.4")
  local_reproducible_output(width = 1000)
  expect_snapshot(
    error = TRUE,
    quarto_create_project(name = "test"),
    transform = transform_quarto_cli_in_output(full_path = TRUE, version = TRUE),
    variant = "before-1-4"
  )
})
