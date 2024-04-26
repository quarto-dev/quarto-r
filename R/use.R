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
#'
#' @param quiet Suppress warnings and messages.
#'
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
quarto_use_template <- function(template, no_prompt = FALSE, quiet = FALSE, quarto_args = NULL) {
  rlang::check_required(template)

  quarto_bin <- find_quarto()

  # This will ask for approval or stop installation
  approval <- check_extension_approval(no_prompt, "Quarto templates", "https://quarto.org/docs/extensions/formats.html#distributing-formats")

  if (approval) {

    # quarto use template does not support `--quiet` so we mimic it by suppressing `echo` in processx
    # TODO: Change if / when https://github.com/quarto-dev/quarto-cli/issues/8438
    args <- c("template", template, "--no-prompt", quarto_args)

    if (quarto_version() > "1.5.4" & isTRUE(quiet)) {
      args <- cli_arg_quiet(args)
    }

    quarto_use(args, quarto_bin = quarto_bin, echo = !quiet)

  }

  invisible()
}

quarto_use <- function(args = character(), ...) {
  quarto_run_what("use", args = args, ...)
}
