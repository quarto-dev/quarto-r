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
