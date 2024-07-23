#' Path to the quarto binary
#'
#' Determine the path to the quarto binary. Uses `QUARTO_PATH` environment
#' variable if defined, otherwise uses `Sys.which()`.
#'
#' @return Path to quarto binary (or `NULL` if not found)
#'
#' @export
quarto_path <- function() {
  path_env <- get_quarto_path_env()
  if (is.na(path_env)) {
    path <- unname(Sys.which("quarto"))
    if (nzchar(path)) path else NULL
  } else {
    path_env
  }
}

get_quarto_path_env <- function() {
  Sys.getenv("QUARTO_PATH", unset = NA_character_)
}

quarto_not_found_msg <- c(
  "Quarto command-line tools path not found! ",
  "Please make sure you have installed and added Quarto to your PATH or set the QUARTO_PATH environment variable."
)

find_quarto <- function() {
  path <- quarto_path()
  if (is.null(path)) {
    cli::cli_abort(quarto_not_found_msg)
  } else {
    return(path)
  }
}

#' Check quarto version
#'
#' Determine the specific version of quarto binary found by [quarto_path()].
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
  res <- tryCatch(
    {
      processx::run(quarto_bin, args = args, echo = echo, error_on_status = TRUE, echo_cmd = echo_cmd, ...)
    },
    error = function(e) {
      msg <- c(x = "Error running quarto cli.")
      if (cli_arg_quiet() %in% args) msg <- c(msg, "i" = "Rerun with `quiet = FALSE` to see the full error message.")
      cli::cli_abort(msg, call = .call, parent = e)
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
      i = "You are using {.strong {quarto_version()}} from {.file {quarto_path()}}."
    ))
  }
}

#' Check configurations for quarto binary used
#'
#' This function check the configuration for the quarto package R package to
#' detect a possible difference with version used by RStudio IDE.
#'
#' @param verbose if `FALSE`, only return the result of the check.
#' @param debug if `TRUE`, print more information about value set in configurations.
#'
#' @returns `TRUE` if this package should be using the same quarto binary as the
#'   RStudio IDE. `FALSE` otherwise if a difference is detected or quarto is not
#'   found. Use `verbose = TRUE` or`debug = TRUE` to get detailed information.
#' @examples
#' quarto_binary_sitrep(verbose = FALSE)
#' quarto_binary_sitrep(verbose = TRUE)
#' quarto_binary_sitrep(debug = TRUE)
#'
#' @export
quarto_binary_sitrep <- function(verbose = TRUE, debug = FALSE) {
  quarto_found <- quarto_path()
  if (is.null(quarto_found)) {
    if (verbose) {
      cli::cli_alert_danger(quarto_not_found_msg)
    }
    return(FALSE)
  }

  quarto_found <- normalizePath(quarto_found, mustWork = FALSE)

  same_config <- TRUE
  if (debug) verbose <- TRUE


  # Quarto R package situation ----
  if (verbose) {
    cli::cli_alert_success(c("i" = "quarto R package will use {.path {quarto_found}}"))
  }

  quarto_r_env <- normalizePath(get_quarto_path_env(), mustWork = FALSE)
  quarto_system <- normalizePath(unname(Sys.which("quarto")), mustWork = FALSE)
  # quarto R package will use QUARTO_PATH env var with higher priority than latest version on path $PATH
  # and RStudio IDE does not use this environment variable
  if (!is.na(quarto_r_env) && identical(quarto_r_env, quarto_found)) {
    same_config <- FALSE
    if (verbose) {
      cli::cli_alert_warning(c(
        "It is configured through {.envvar QUARTO_PATH} environment variable. ",
        "RStudio IDE will likely use another binary."
      ))
    }
  } else if (nzchar(quarto_system) && identical(quarto_system, quarto_found)) {
    if (debug) {
      cli::cli_alert_info(c(
        "    It is configured to use the latest version found in the {.emph PATH} environment variable."
      ))
    }
  }

  # RStudio IDE known situation ----

  # RStudio IDE > Render button will use RSTUDIO_QUARTO env var with higher priority than latest version on path $PATH
  rstudio_env <- Sys.getenv("RSTUDIO_QUARTO", unset = NA)
  if (!is.na(rstudio_env)) {
    rstudio_env <- normalizePath(rstudio_env, mustWork = FALSE)
    if (!identical(rstudio_env, quarto_found)) {
      same_config <- FALSE
      if (verbose) {
        cli::cli_alert_danger(c(
          "RStudio IDE render button seems configured to use {.path {rstudio_env}}."
        ))
        if (debug) {
          cli::cli_alert_warning(c(
            "    It is configured through {.envvar RSTUDIO_QUARTO} environment variable."
          ))
        }
      }
    }
  }

  return(same_config)
}
