
test_that("An error is reported when Quarto is not installed", {
  skip_if(!is.null(quarto_path()))
  expect_error(quarto_render("test.Rmd"))
})


test_that("R Markdown documents can be rendered", {
  skip_if(is.null(quarto_path()))
  quarto_render("test.Rmd", quiet = TRUE)
  expect_true(file.exists("test.html"))
  unlink("test.html")
})
