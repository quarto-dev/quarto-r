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
      if (cli_arg_quiet() %in% args) msg <- c(msg, "i" = "Rerun with `quiet = FALSE` to see the full error message.")
      rlang::abort(msg, call = .call, parent = e)
    }
  )
  invisible(res)
}

quarto_run_what <- function(what = character(), args = character(), quarto_bin = find_quarto(), echo = FALSE, ..., .call = rlang::caller_env()) {
  res <- quarto_run(quarto_bin, args = c(what, args), echo = echo, ..., .call = .call)
  invisible(res)
}

#' Check is a directory is using quarto
#'
#' This function will check if a directory is using quarto by looking for
#' - `_quarto.yml` at its root
#' - at least one `.qmd` file in the directory
#'
#' @param dir The directory to check
#' @param verbose print message about the result of the check
#' @examples
#' dir.create(tmpdir <- tempfile())
#' is_using_quarto(tmpdir)
#' file.create(file.path(tmpdir, "_quarto.yml"))
#' is_using_quarto(tmpdir)
#' unlink(tmpdir, recursive = TRUE)
#' @export
is_using_quarto <- function(dir = ".", verbose = FALSE) {
  has_quarto_yml <- length(list.files(dir, pattern = "_quarto\\.yml$", full.names = TRUE)) > 0
  has_qmd <- length(list.files(dir, pattern = "\\.qmd$", full.names = TRUE)) > 0
  if (has_quarto_yml) {
    if (verbose) cli::cli_inform("A {.file _quarto.yml} has been found.")
    return(TRUE)
  } else if (has_qmd) {
    if (verbose) cli::cli_inform("At least one file {.code *.qmd} has been found.")
    return(TRUE)
  }
  # not a directory using Quarto
  if (verbose) cli::cli_inform("No {.file _quarto.yml} or {.code *.qmd} has been found.")
  return(FALSE)
}

check_quarto_version <- function(ver, what, url) {
  if (quarto_version() < ver) {
    cli::cli_abort(c(
      "{.code {what}} has been added in Quarto {ver}. See {.url {url}}.",
      i = "You are using {.strong {quarto_version()}} from {.file {quarto_path()}}.")
    )
  }
}

quarto_bin_sitrep <- function() {
  cli::cli_h1("Quarto binary found")
  cli::cli_h2("This R package configuration")
  if (nzchar(quarto_path())) {
    cli::cli_inform("Functions in this package will use {.path {quarto_path()}}")
  } else {
    cli::cli_alert_danger("No {.strong quarto} binary found.")
  }
  cli::cli_h2("RStudio IDE configuration with RSTUDIO_QUARTO environment variable.")
  rstudio_env <- Sys.getenv("RSTUDIO_QUARTO", unset = "")
  if (nzchar(rstudio_env)) {
    cli::cli_inform(c(
      "{.envvar RSTUDIO_QUARTO} environment variable is set.",
      "RStudio is configured to use {.path {rstudio_env}}"
    ))
  } else {
    cli::cli_inform(c(
      "{.envvar RSTUDIO_QUARTO} environment variable is not set.",
      "RStudio IDE should use the {.strong quarto} binary found in the {.emph PATH} environment variable."
    ))
  }
  cli::cli_h2("quarto R package configuration with {.envvar QUARTO_PATH} environment variable.")
  quarto_r_env <- Sys.getenv("QUARTO_PATH", unset = "")
  if (nzchar(quarto_r_env)) {
    cli::cli_inform(c(
      "{.envvar QUARTO_PATH} environment variable is set.",
      "{.pkg quarto} R package is configured to use {.path {quarto_r_env}}"
    ))
  } else {
    cli::cli_inform(c(
      "{.envvar QUARTO_PATH} environment variable is not set.",
      "{.pkg quarto} R package should use the {.strong quarto} binary found in the {.emph PATH} environment variable."
    ))
  }
  cli::cli_h2("Configuration from {.envvar PATH} environment variable.")
  path_quarto <- Sys.which("quarto")
  if (nzchar(path_quarto)) {
    cli::cli_inform("The {.strong quarto} binary found in the {.envvar PATH} environment variable is {.path {path_quarto}}")
  } else {
    cli::cli_inform("No {.strong quarto} binary found in the {.envvar PATH} environment variable is not found.")
  }
}
