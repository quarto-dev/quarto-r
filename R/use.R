#' Use a custom format extension template
#'
#' Install and use a template for Quarto using `quarto use`.
#'
#' @inheritParams quarto_add_extension
#'
#' @param template The template to install, either an archive or a GitHub
#'   repository as described in the documentation
#'   <https://quarto.org/docs/extensions/formats.html>.
#'
#' @examples
#' \dontrun{
#' # Install a template and set up a draft document from a GitHub repository
#' quarto_use_template("quarto-journals/jss")
#'
#' # Install a template and set up a draft document from a ZIP archive
#' quarto_use_template("https://github.com/quarto-journals/jss/archive/refs/heads/main.zip")
#' }
#'
#' @export
quarto_use_template <- function(template, no_prompt = FALSE) {
  rlang::check_required(template)

  quarto_bin <- find_quarto()

    # This will ask for approval or stop installation
  check_extension_approval(no_prompt, "Quarto templates", "https://quarto.org/docs/extensions/formats.html#distributing-formats")

  args <- c("template", template, "--no-prompt")

  quarto_use(args, quarto_bin = quarto_bin, echo = TRUE)

  invisible()
}

quarto_use_binder <- function(no_prompt = FALSE) {
  if (quarto_version() < 1.4) {
    cli::cli_abort(c(
      "{.code quarto use binder} has been added in Quarto 1.4. See {.url https://quarto.org/docs/projects/binder.html}.",
      i = "You are using {.strong {quarto_version()}} from {.file {quarto_path()}}.")
    )
  }

  quarto_bin <- find_quarto()

  args <- c("binder", if (no_prompt) "--no-prompt")

  quarto_use(args, quarto_bin = quarto_bin, echo = TRUE)

}

quarto_use <- function(args = character(), ...) {
  quarto_run_what("use", args = args, ...)
}
