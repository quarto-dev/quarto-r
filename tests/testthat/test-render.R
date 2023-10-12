
test_that("An error is reported when Quarto is not installed", {
  skip_if_quarto()
  expect_error(quarto_render("test.Rmd"))
})


test_that("R Markdown documents can be rendered", {
  skip_if_no_quarto()
  quarto_render("test.Rmd", quiet = TRUE)
  expect_true(file.exists("test.html"))
  unlink("test.html")
})
