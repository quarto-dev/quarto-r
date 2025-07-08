#' Use a custom format extension template
#'
#' Install and use a template for Quarto using `quarto use`.
#'
#' @inheritParams quarto_render
#' @inheritParams quarto_add_extension
#'
#' @param template The template to install, either an archive or a GitHub
#'   repository as described in the documentation
#'   <https://quarto.org/docs/extensions/formats.html>.
#' @param dir The directory in which to install the template. This must be an empty directory.
#'   To use directly in a non-empty directory, use `quarto use template` interactively in the terminal for safe installation
#'   without overwrite.
#' @param quiet Suppress warnings and messages.
#'
#'
#' @examples
#' \dontrun{
#' # Use a template and set up a draft document from a GitHub repository
#' quarto_use_template("quarto-journals/jss")
#'
#' # Use a template in current directory by installing it in an empty directory
#' quarto_use_template("quarto-journals/jss", dir = "new-empty-dir")
#'
#' # Use a template and set up a draft document from a ZIP archive
#' quarto_use_template("https://github.com/quarto-journals/jss/archive/refs/heads/main.zip")
#' }
#'
#' @export
quarto_use_template <- function(
  template,
  dir = ".",
  no_prompt = FALSE,
  quiet = FALSE,
  quarto_args = NULL
) {
  rlang::check_required(template)

  if (!fs::dir_exists(dir)) {
    fs::dir_create(dir)
  }

  if (!is_empty_dir(dir) && quarto_available("1.5.15")) {
    cli::cli_abort(c(
      "{.arg dir} must be an empty directory.",
      "x" = "The directory {.path {dir}} is not empty.",
      " " = "Please provide an empty directory or use {.code quarto use template {template} } interactively in terminal."
    ))
  }

  quarto_bin <- find_quarto()

  # This will ask for approval or stop installation
  approval <- check_extension_approval(
    no_prompt,
    "Quarto templates",
    "https://quarto.org/docs/extensions/formats.html#distributing-formats"
  )

  if (approval) {
    # quarto use template does not support `--quiet` so we mimic it by suppressing `echo` in processx
    # TODO: Change if / when https://github.com/quarto-dev/quarto-cli/issues/8438
    args <- c("template", template, "--no-prompt", quarto_args)

    if (quarto_version() > "1.5.4" && is_quiet(quiet)) {
      args <- cli_arg_quiet(args)
    }
    xfun::in_dir(
      dir,
      quarto_use(args, quarto_bin = quarto_bin, echo = !quiet)
    )
  }

  invisible()
}

quarto_use <- function(args = character(), ...) {
  quarto_run_what("use", args = args, ...)
}
