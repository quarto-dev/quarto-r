check_extension_approval <- function(no_prompt = FALSE, what = "Something", see_more_at = NULL) {
  if (no_prompt) return(TRUE)

  if (!is_interactive()) {
    cli::cli_abort(c(
      "{ what } requires explicit approval.",
      ">" = "Set {.arg no_prompt = TRUE} if you agree.",
      if (!is.null(see_more_at)) {
        c(i = "See more at {.url {see_more_at}}")
      }
    ))
  } else {
    cli::cli_inform(c(
      "{what} may execute code when documents are rendered. ",
      "*" = "If you do not trust the author(s) of this {what}, we recommend that you do not install or use this {what}."
    ))
    prompt_value <- tolower(readline(sprintf("Do you trust the authors of this %s (Y/n)? ", what)))
    if (!prompt_value %in% "y") {
      cli::cli_inform("{what} not installed.")
      return(invisible(FALSE))
    }
    return(invisible(TRUE))
  }
}

check_removal_approval <- function(no_prompt = FALSE, what = "Something", see_more_at = NULL) {
  if (no_prompt) return(TRUE)

  if (!is_interactive()) {
    cli::cli_abort(c(
      "{ what } requires explicit approval.",
      ">" = "Set {.arg no_prompt = TRUE} if you agree.",
      if (!is.null(see_more_at)) {
        c(i = "See more at {.url {see_more_at}}")
      }
    ))
  } else {
    prompt_value <- tolower(readline(sprintf("? Are you sure you'd like to remove %s (Y/n)? ", what)))
    if (!prompt_value %in% "y") {
      return(invisible(FALSE))
    }
    return(invisible(TRUE))
  }
}

# Add binding to base R function for testthat mocking
readline <- NULL
# Add binding to function from other package for mocking later on
is_interactive <- function(...) {
  rlang::is_interactive(...)
}
