test_that("An error is reported when Quarto is not installed", {
  skip_if(!is.null(quarto_path()))
  expect_error(quarto_render("test.Rmd"))
})


test_that("R Markdown documents can be rendered", {
  skip_if(is.null(quarto_path()))
  quarto_render("test.Rmd", quiet = TRUE)
  expect_true(file.exists("test.html"))
  unlink("test-render.html")
})


test_that("`quarto_render()` is wrapable", {
  skip_if(is.null(quarto_path()))
  skip_if_not_installed("rstudioapi")
  skip_if_not_installed("rprojroot")
  skip_if(!rstudioapi::isAvailable())
  dir <- rprojroot::find_testthat_root_file()
  input <- file.path(dir, "test.Rmd")
  output <- file.path(dir, "test.html")
  wrapper <- function(path) quarto_render(path, quiet = TRUE)
  wrapper(input)
  expect_true(file.exists(output))
  unlink(output)
})
