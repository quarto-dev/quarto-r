cli_arg_profile <- function(profile, ...) {
  arg <- c("--profile", paste0(profile, collapse = ","))
  append_cli_args(arg, ...)
}

is_quiet <- function(quiet) {
  # in CI, follow debug mode 
  if (identical(Sys.getenv("ACTIONS_RUNNER_DEBUG", ""), "true") || identical(Sys.getenv("ACTIONS_STEP_DEBUG", ""), "true")) {
    return(FALSE)
  }
  # these option takes precedence
  quiet_options <- getOption("quarto.quiet", Sys.getenv("QUARTO_R_QUIET", NA))
  if (!is.na(quiet_options)) return(isTRUE(as.logical(quiet_options)))
  isTRUE(quiet)
}

cli_arg_quiet <- function(...) {
  append_cli_args("--quiet", ...)
}

append_cli_args <- function(new, append_to = NULL, after = length(append_to)) {
  if (!is.null(append_to)) {
    return(append(append_to, new, after))
  }
  new
}
