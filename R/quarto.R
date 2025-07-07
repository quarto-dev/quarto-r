#' Path to the quarto binary
#'
#' Determine the path to the quarto binary. Uses `QUARTO_PATH` environment
#' variable if defined, otherwise uses `Sys.which()`.
#'
#' @param normalize If `TRUE` (default), normalize the path using [base::normalizePath()].
#'
#' @return Path to quarto binary (or `NULL` if not found)
#'
#' @seealso [quarto_version()] to check the version of the binary found, [quarto_available()] to check if Quarto CLI is available and meets some requirements.
#'
#' @export
quarto_path <- function(normalize = TRUE) {
  path_env <- get_quarto_path_env()
  quarto_path <- if (is.na(path_env)) {
    path <- unname(Sys.which("quarto"))
    if (nzchar(path)) path else return(NULL)
  } else {
    path_env
  }
  if (!normalize) {
    return(quarto_path)
  }
  xfun::normalize_path(quarto_path)
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
#' @seealso [quarto_available()] to check if the version meets some requirements.
#' @export
quarto_version <- function() {
  quarto_bin <- find_quarto()
  as.numeric_version(system2(quarto_bin, "--version", stdout = TRUE))
}


#' Check if quarto is available and version meet some requirements
#'
#' This function allows to test if Quarto is available and meets version requirement, a min, max or
#' in between requirement.
#'
#' If `min` and `max` are provided, this will check if Quarto version is
#' in-between two versions. If non is provided (keeping the default `NULL` for
#' both), it will just check for Quarto availability version and return `FALSE` if not found.
#'
#' @param min Minimum version expected.
#' @param max Maximum version expected
#' @param error If `TRUE`, will throw an error if Quarto is not available or does not meet the requirement. Default is `FALSE`.
#'
#' @return logical. `TRUE` if requirement is met, `FALSE` otherwise.
#'
#' @examples
#' # Is there an active version available ?
#' quarto_available()
#' # check for a minimum requirement
#' quarto_available(min = "1.5")
#' # check for a maximum version
#' quarto_available(max = "1.6")
#' # only returns TRUE if Pandoc version is between two bounds
#' quarto_available(min = "1.4", max = "1.6")
#'
#' @export
quarto_available <- function(min = NULL, max = NULL, error = FALSE) {
  found <- FALSE
  is_above <- is_below <- TRUE
  if (!is.null(min) && !is.null(max)) {
    if (min > max) {
      cli::cli_abort(c(
        "Minimum version {.strong {min}} cannot be greater than maximum version {.strong {max}}."
      ))
    }
  }
  quarto_version <- tryCatch(
    quarto_version(),
    error = function(e) NULL
  )
  if (!is.null(quarto_version)) {
    if (!is.null(min)) {
      is_above <- quarto_version >= min
    }
    if (!is.null(max)) {
      is_below <- quarto_version <= max
    }
    found <- is_above && is_below
  }
  if (!found && error) {
    cli::cli_abort(c(
      if (is.null(min) && is.null(max)) {
        "Quarto is not available."
      } else {
        "Quarto version requirement not met."
      },
      "*" = if (!is_above) {
        paste0(" Minimum version expected is ", min, ".")
      },
      "*" = if (!is_below) {
        paste0(" Maximum version expected is ", max, ".")
      }
    ))
  }
  return(found)
}

#' @importFrom processx run
quarto_run <- function(
  args = character(),
  quarto_bin = find_quarto(),
  echo = FALSE,
  echo_cmd = getOption("quarto.echo_cmd", FALSE),
  ...,
  .call = rlang::caller_env()
) {
  # This is required due to a bug in QUARTO CLI, fixed only in 1.8+
  # https://github.com/quarto-dev/quarto-cli/pull/12887
  custom_env <- NULL
  if (!quarto_available(min = "1.8.13")) {
    custom_env <- c("current", QUARTO_R = R.home("bin"))
  }
  res <- withCallingHandlers(
    processx::run(
      quarto_bin,
      args = args,
      echo = echo,
      error_on_status = TRUE,
      echo_cmd = echo_cmd,
      env = custom_env,
      ...
    ),
    system_command_status_error = function(e) {
      wrap_quarto_error(e, args, .call = .call)
    },
    error = function(e) {
      cli::cli_abort(
        c("!" = "Error running quarto CLI from R."),
        call = .call,
        parent = e
      )
    }
  )

  invisible(res)
}

quarto_run_what <- function(
  what = character(),
  args = character(),
  quarto_bin = find_quarto(),
  echo = FALSE,
  ...,
  .call = rlang::caller_env()
) {
  res <- quarto_run(
    quarto_bin,
    args = c(what, args),
    echo = echo,
    ...,
    .call = .call
  )
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
  has_quarto_yml <- length(list.files(
    dir,
    pattern = "_quarto\\.yml$",
    full.names = TRUE
  )) >
    0
  has_qmd <- length(list.files(dir, pattern = "\\.qmd$", full.names = TRUE)) > 0
  if (has_quarto_yml) {
    if (verbose) {
      cli::cli_inform("A {.file _quarto.yml} has been found.")
    }
    return(TRUE)
  } else if (has_qmd) {
    if (verbose) {
      cli::cli_inform("At least one file {.code *.qmd} has been found.")
    }
    return(TRUE)
  }
  # not a directory using Quarto
  if (verbose) {
    cli::cli_inform("No {.file _quarto.yml} or {.code *.qmd} has been found.")
  }
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

  quarto_found <- xfun::normalize_path(quarto_found)

  same_config <- TRUE
  if (debug) {
    verbose <- TRUE
  }

  # Quarto R package situation ----
  if (verbose) {
    cli::cli_alert_success(c(
      "i" = "quarto R package will use {.path {quarto_found}}"
    ))
  }

  quarto_r_env <- xfun::normalize_path(get_quarto_path_env())
  quarto_system <- xfun::normalize_path(unname(Sys.which("quarto")))
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
    rstudio_env <- xfun::normalize_path(rstudio_env)
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


wrap_quarto_error <- function(cnd, args, .call = rlang::caller_env()) {
  msg <- c(x = "Error returned by quarto CLI.")
  # if there is an error message from quarto CLI, add it to the message
  if (cnd$stderr != "") {
    quarto_error_msg <- xfun::split_lines(cnd$stderr)
    names(quarto_error_msg) <- rep(" ", length(quarto_error_msg))
    msg <- c(
      msg,
      " " = paste0(rep("-", nchar(msg)), collapse = ""),
      quarto_error_msg
    )
  }

  # if `--quiet` has been set, quarto CLI won't report any error (cnd$stderr will be empty)
  # So remind user to run without `--quiet` to see the full error message
  if (cli_arg_quiet() %in% args) {
    msg <- c(
      msg,
      "i" = "Rerun with `quiet = FALSE` to see the full error message."
    )
  }

  cli::cli_abort(
    msg,
    call = .call,
    parent = cnd,
  )
}
