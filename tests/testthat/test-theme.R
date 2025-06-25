# don't run on CRAN - this require installed Quarto version with the right version of the quarto package.
skip_on_cran()
skip_if_no_quarto()
skip_if_not_installed("withr")

# We need to install the package in a temporary library when we are in dev mode
install_dev_package()

theme_file <- function(...) {
  test_path("theme", ...)
}

resource_dir <- function(input) {
  theme_file(
    paste0(fs::path_ext_remove(basename(input)), "_files")
  )
}

local_render_theme_file <- function(input, env = parent.frame()) {
  skip_if_not_installed("withr")
  withr::defer(
    {
      # clean up output resource directory
      out_dir <- resource_dir(input)
      if (fs::dir_exists(out_dir)) {
        fs::dir_delete(out_dir)
      }
      # clean up internal .quarto directory
      if (fs::dir_exists(".quarto")) {
        fs::dir_delete(".quarto")
      }
    },
    envir = env
  )
}

test_that("render flextable", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("flextable")
  file <- theme_file("flextable.qmd")
  local_render_theme_file(file)
  .render(file)
})

test_that("render ggiraph", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("ggiraph")
  file <- theme_file("ggiraph.qmd")
  local_render_theme_file(file)
  .render(file)
})

test_that("render ggplot2", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("ggplot2")
  file <- theme_file("ggplot2.qmd")
  local_render_theme_file(file)
  .render(test_path(file))
})

test_that("render gt", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("gt")
  file <- theme_file("gt.qmd")
  local_render_theme_file(file)
  .render(file)
})

test_that("render plotly-r", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("plotly")
  file <- theme_file("plotly-r.qmd")
  local_render_theme_file(file)
  .render(file)
})

test_that("render thematic", {
  skip_if_not_installed("bslib")
  skip_if_not_installed("thematic")
  file <- theme_file("thematic.qmd")
  local_render_theme_file(file)
  .render(file)
})
