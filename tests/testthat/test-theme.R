# don't run on CRAN - this require installed Quarto version with the right version of the quarto package.
skip_on_cran()
skip_if_no_quarto()
skip_if_not_installed("withr")

# We need to install the package in a temporary library when we are in dev mode
install_dev_package()

test_that("render flextable", {
  .render(test_path("theme/flextable.qmd"))
})

test_that("render ggiraph", {
  .render(test_path("theme/ggiraph.qmd"))
})

test_that("render ggplot", {
  .render(test_path("theme/ggplot.qmd"))
})

test_that("render gt", {
  .render(test_path("theme/gt.qmd"))
})

test_that("render plotly-r", {
  .render(test_path("theme/plotly-r.qmd"))
})

test_that("render thematic", {
  .render(test_path("theme/thematic.qmd"))
})
