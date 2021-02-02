#' Path to the quarto binary
#'
#' Determine the path to the quarto binary. Uses `QUARTO_PATH` environment
#' variable if defined, otherwise uses `Sys.which()`.
#'
#' @return Path to quarto binary (or `NULL` if not found)
#'
#' @export
quarto_path <- function() {
  path_env <- Sys.getenv("QUARTO_PATH", unset = NA)
  if (is.na(path_env)) {
    path <- unname(Sys.which("quarto"))
    if (nzchar(path)) path else NULL
  } else {
    path_env
  }
}

find_quarto <- function() {
  path <- quarto_path()
  if (is.null(path)) {
    stop("Unable to find quarto command line tools.")
  } else {
    path
  }
}
