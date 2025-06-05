# don't run on CRAN - this require installed Quarto version with the right version of the quarto package.
skip_on_cran()
skip_if_no_quarto()
skip_if_not_installed("withr")

# We need to install the package in a temporary library when we are in dev mode
install_dev_package()

test_that("render flextable", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("flextable")
  .render(test_path("theme/flextable.qmd"))
})

test_that("render ggiraph", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("ggiraph")
  .render(test_path("theme/ggiraph.qmd"))
})

test_that("render ggplot2", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("ggplot2")
  .render(test_path("theme/ggplot2.qmd"))
})

test_that("render gt", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("gt")
  .render(test_path("theme/gt.qmd"))
})

test_that("render plotly-r", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("plotly")
  .render(test_path("theme/plotly-r.qmd"))
})

test_that("render thematic", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("thematic")
  .render(test_path("theme/thematic.qmd"))
})
