
test_that("render flextable", {
  skip_if_no_quarto()
  quarto_render("theme/flextable.qmd", quiet = TRUE)
  expect_true(file.exists("theme/flextable.html"))
  unlink("theme/flextable.html")
})


test_that("render ggiraph", {
  skip_if_no_quarto()
  quarto_render("theme/ggiraph.qmd", quiet = TRUE)
  expect_true(file.exists("theme/ggiraph.html"))
  unlink("theme/ggiraph.html")
})


test_that("render ggplot", {
  skip_if_no_quarto()
  quarto_render("theme/ggplot.qmd", quiet = TRUE)
  expect_true(file.exists("theme/ggplot.html"))
  unlink("theme/ggplot.html")
})


test_that("render gt", {
  skip_if_no_quarto()
  quarto_render("theme/gt.qmd", quiet = TRUE)
  expect_true(file.exists("theme/gt.html"))
  unlink("theme/gt.html")
})


test_that("render heatmaply", {
  skip_if_no_quarto()
  quarto_render("theme/heatmaply.qmd", quiet = TRUE)
  expect_true(file.exists("theme/heatmaply.html"))
  unlink("theme/heatmaply.html")
})


test_that("render plotly-r", {
  skip_if_no_quarto()
  quarto_render("theme/plotly-r.qmd", quiet = TRUE)
  expect_true(file.exists("theme/plotly-r.html"))
  unlink("theme/plotly-r.html")
})


test_that("render thematic", {
  skip_if_no_quarto()
  quarto_render("theme/thematic.qmd", quiet = TRUE)
  expect_true(file.exists("theme/thematic.html"))
  unlink("theme/thematic.html")
})

