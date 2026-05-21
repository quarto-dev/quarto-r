cli_arg_profile <- function(profile, ...) {
  arg <- c("--profile", paste0(profile, collapse = ","))
  append_cli_args(arg, ...)
}

is_quiet <- function(quiet) {
  # in CI, follow debug mode
  if (in_ci_with_debug()) {
    return(FALSE)
  }
  # these option takes precedence
  quiet_options <- xfun::env_option("quarto.quiet", default = NA)
  if (!is.na(quiet_options)) {
    return(isTRUE(as.logical(quiet_options)))
  }
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

cli_arg_metadata <- function(metadata = NULL, metadata_file = NULL) {
  if (is.null(metadata) && is.null(metadata_file)) {
    return(list(args = character(), tmp_file = NULL))
  }
  if (is.null(metadata)) {
    return(list(
      args = c("--metadata-file", metadata_file),
      tmp_file = NULL
    ))
  }
  if (!is.null(metadata_file)) {
    file_content <- yaml::read_yaml(metadata_file, eval.expr = FALSE)
    metadata <- merge_list(file_content, metadata)
  }
  tmp <- tempfile(pattern = "quarto-meta", fileext = ".yml")
  # Remove tmp if write_yaml() errors before we hand the path to the
  # caller; the caller (e.g. quarto_render()) registers its own
  # on.exit cleanup for the success path.
  success <- FALSE
  on.exit(if (!success) unlink(tmp), add = TRUE)
  write_yaml(metadata, tmp)
  success <- TRUE
  list(
    args = c("--metadata-file", tmp),
    tmp_file = tmp
  )
}
