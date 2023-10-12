skip_if_no_quarto <- function() {
  skip_if(is.null(quarto_path()))
}

skip_if_quarto <- function() {
  skip_if(!is.null(quarto_path()))
}

local_qmd_file <- function(..., .env = parent.frame()) {
  skip_if_not_installed("xfun")
  skip_if_not_installed("withr")
  path <- withr::local_tempfile(.local_envir = .env, fileext = ".qmd")
  xfun::write_utf8(c(...), path)
  path
}

.render <- function(input, ...) {
  skip_if_no_quarto()
  output_file <- xfun::with_ext(basename(input), "test.out")
  quarto_render(input, output_file = output_file, quiet = TRUE, ...)
  output_file
}

.render_and_read <- function(input, ...) {
  skip_if_not_installed("xfun")
  skip_if_not_installed("withr")
  out <- .render(input, ...)
  withr::local_dir(dirname(input))
  xfun::read_utf8(out)
}
