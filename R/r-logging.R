in_debug_mode <- function() {
  in_ci_with_debug() || quarto_log_level("DEBUG") || is_quarto_r_debug()
}

in_ci_with_debug <- function() {
  # check for GitHub Actions debug mode
  # https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
  gha_debug <- Sys.getenv("ACTIONS_RUNNER_DEBUG", "") == "true" ||
    Sys.getenv("ACTIONS_STEP_DEBUG", "") == "true"
  return(gha_debug)
}

# Return the current log level for Quarto
# unless level is provided, in which case
# it checks if the current log level matches the provided level.
quarto_log_level <- function(level = NULL) {
  log_level <- Sys.getenv("QUARTO_LOG_LEVEL", NA)
  if (is.null(level)) {
    return(log_level)
  }
  return(identical(tolower(log_level), tolower(level)))
}

#' @importFrom xfun env_option
is_quarto_r_debug <- function() {
  # check option first, then environment variable
  # to allow setting in the R session
  # env var R_QUARTO_LOG_DEBUG
  isTRUE(as.logical(xfun::env_option('quarto.log.debug', FALSE)))
}

# Get the configured log file path
# Uses xfun::env_option to check for log file configuration
# with option 'quarto.log.file' and env var 'R_QUARTO_LOG_FILE'
#' @importFrom xfun env_option
get_log_file <- function() {
  xfun::env_option('quarto.log.file', default = "./quarto-r-debug.log")
}

#' Log debug information to a configurable file
#'
#' This function logs messages to a file only when in debug mode to help diagnose
#' issues with Quarto vignettes in **pkgdown** and other contexts.
#'
#' Debug mode will be enabled automatically when debugging Github Actions workflows,
#' or when Quarto CLI's environment variable `QUARTO_LOG_LEVEL` is set to `DEBUG`.
#'
#' @param ... Messages to log (will be concatenated)
#' @param file Path to log file. If NULL, uses `get_log_file()` to determine the file.
#'   Default will be `./quarto-r-debug.log` if no configuration is found.
#' @param append Logical. Should the messages be appended to the file? Default TRUE.
#' @param timestamp Logical. Should a timestamp be added? Default TRUE.
#' @param prefix Character. Prefix to add before each log entry. Default "DEBUG: ".
#'
#' @return Invisibly returns TRUE if logging occurred, FALSE otherwise
#' @keywords internal
#'
#' @section Configuration:
#'
#' **Enable debugging messages:**
#' - Set `quarto.log.debug = TRUE` (or `R_QUARTO_LOG_DEBUG = TRUE` environment variable)
#'
#' **Change log file path:**
#' - Set `quarto.log.file` to change the file path (or `R_QUARTO_LOG_FILE` environment variable)
#' - Default will be `./quarto-r-debug.log`
#'
#' **Automatic debug mode:**
#' - Debug mode will be on automatically when debugging Github Actions workflows
#' - When Quarto CLI's environment variable `QUARTO_LOG_LEVEL` is set to `DEBUG`
#'
#' @examples
#' \dontrun{
#' # Set log file via environment variable
#' Sys.setenv(R_QUARTO_LOG_FILE = "~/quarto-debug.log")
#'
#' # Or via option
#' options(quarto.log.file = "~/quarto-debug.log")
#'
#' # Enable debug mode
#' options(quarto.log.debug = TRUE)
#'
#' # Log some information
#' quarto_log("Starting process")
#' quarto_log("R_LIBS:", Sys.getenv("R_LIBS"))
#' quarto_log(".libPaths():", paste0(.libPaths(), collapse = ":"))
#' }
quarto_log <- function(
  ...,
  file = NULL,
  append = TRUE,
  timestamp = TRUE,
  prefix = "DEBUG: "
) {
  if (!in_debug_mode()) {
    return(invisible(FALSE))
  }

  if (is.null(file)) {
    file <- get_log_file()
  }

  # get_log_file() now returns the default, so no need for additional fallback

  # Construct the message
  msg_parts <- list(...)
  msg <- paste(msg_parts, collapse = "")

  # Add prefix if provided
  if (!is.null(prefix) && nchar(prefix) > 0) {
    msg <- paste0(prefix, msg)
  }

  # Add timestamp if requested
  if (timestamp) {
    ts <- format(Sys.time(), "[%Y-%m-%d %H:%M:%S] ")
    msg <- paste0(ts, msg)
  }

  # Ensure message ends with newline
  if (!grepl("\n$", msg)) {
    msg <- paste0(msg, "\n")
  }

  # Write to file
  tryCatch(
    {
      cat(msg, file = file, append = append)
      return(invisible(TRUE))
    },
    error = function(e) {
      # If we can't write to the file, fail silently in debug logging
      return(invisible(FALSE))
    }
  )
}
