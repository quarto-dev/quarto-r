check_approval <- function(
  no_prompt = FALSE,
  what = "Something",
  not_action = "approved",
  see_more_at = NULL,
  prompt_message = NULL,
  interactive_info = NULL, # could use `{ what }` as used in `cli_inform()`
  .call = rlang::caller_env()
) {
  if (no_prompt) {
    return(TRUE)
  }

  if (!is_interactive()) {
    cli::cli_abort(
      c(
        "{ what } requires explicit approval.",
        ">" = "Set {.arg no_prompt = TRUE} if you agree.",
        if (!is.null(see_more_at)) {
          c(i = "See more at {.url {see_more_at}}")
        }
      ),
      call = .call
    )
  } else {
    if (!is.null(interactive_info)) {
      cli::cli_inform(interactive_info)
    }
    prompt_value <- tolower(readline(prompt_message))
    if (!prompt_value %in% c("", "y")) {
      cli::cli_alert_info(paste0(what, " not {not_action}"))
      return(invisible(FALSE))
    }
  }
  return(invisible(TRUE))
}

check_extension_approval <- function(
  no_prompt = FALSE,
  what = "Something",
  see_more_at = NULL
) {
  interactive_info <- c(
    "{what} may execute code when documents are rendered. ",
    "*" = "If you do not trust the author(s) of this {what}, we recommend that you do not install or use this {what}."
  )

  prompt_message <- sprintf(
    "Do you trust the authors of this %s (Y/n)? ",
    what
  )

  check_approval(
    no_prompt = no_prompt,
    what = what,
    not_action = "installed",
    see_more_at = see_more_at,
    prompt_message = prompt_message,
    interactive_info = interactive_info
  )
}

check_removal_approval <- function(
  no_prompt = FALSE,
  what = "Something",
  see_more_at = NULL
) {
  prompt_message <- sprintf(
    "Are you sure you'd like to remove %s (Y/n)? ",
    what
  )

  check_approval(
    no_prompt = no_prompt,
    what = what,
    not_action = "removed",
    see_more_at = see_more_at,
    prompt_message = prompt_message,
    interactive_info = NULL
  )
}

# Needed for testthat to mock base function
readline <- NULL
