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
     stop("Quarto command-line tools path not found! Please make sure you have installed and added Quarto to your PATH or set the QUARTO_PATH environment variable.")
  } else {
    return(path)
  }
}

#' Check quarto version
#'
#' Determine the specific version of quartobinary found by [quarto_path()].
#' If it returns `99.9.9` then it means you are using a dev version.
#'
#' @return a [`numeric_version`][base::numeric_version] with the quarto version found
#' @export
quarto_version <- function() {
  quarto_bin <- find_quarto()
  as.numeric_version(system2(quarto_bin, "--version", stdout = TRUE))
}

#' @importFrom processx run
quarto_run <- function(args = character(), quarto_bin = find_quarto(), echo = FALSE, echo_cmd = getOption("quarto.echo_cmd", FALSE), ..., .call = rlang::caller_env()) {
  res <- tryCatch({
    processx::run(quarto_bin, args = args, echo = echo, error_on_status = TRUE, echo_cmd = echo_cmd, ...)
  },
    error = function(e) {
      msg <- c("Error running quarto cli:")
      if (nzchar(e$stderr)) msg <- c(msg, "x" = e$stderr)
      if ("--quiet" %in% args) msg <- c(msg, "i" = "Rerun with `quiet = FALSE` to see the full error message.")
      rlang::abort(msg, call = .call, parent = e)
    }
  )
  invisible(res)
}

quarto_run_what <- function(what = character(), args = character(), quarto_bin = find_quarto(), echo = FALSE, ..., .call = rlang::caller_env()) {
  res <- quarto_run(quarto_bin, args = c(what, args), echo = echo, ..., .call = .call)
  invisible(res)
}
