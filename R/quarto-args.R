cli_arg_profile <- function(profile, ...) {
  arg <- c("--profile", paste0(profile, collapse = ","))
  append_cli_args(arg, ...)
}

is_quiet <- function(quiet) {
  # this option takes precedence
  quiet_options <- getOption("quarto.quiet", NA)
  if (!is.na(quiet_options)) return(quiet_options)
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
