cli_arg_profile <- function(profile, ...) {
  arg <- c("--profile", paste0(profile, collapse = ","))
  append_cli_args(arg, ...)
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
