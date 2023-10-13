#' Quarto Add Extension
#'
#' Add an extension to this folder or project.
#'
#' # Extension Trust
#'
#' Quarto extensions may execute code when documents are rendered. Therefore, if
#' you do not trust the author of an extension, we recommend that you do not
#' install or use the extension.
#' By default `no_prompt = FALSE` which means that
#' the function will ask for explicit approval when used interactively, or
#' disallow installation.
#'
#' @param extension The extension to install, either an archive or a GitHub
#'   repository as described in the documentation
#'   <https://quarto.org/docs/extensions/managing.html>.
#' @param no_prompt Do not prompt to confirm approval to download external extension.
#'
#' @examples
#' \dontrun{
#' # Install a template and set up a draft document from a GitHub repository
#' quarto_add_extension("quarto-ext/fontawesome")
#'
#' # Install a template and set up a draft document from a ZIP archive
#' quarto_add_extension("https://github.com/quarto-ext/fontawesome/archive/refs/heads/main.zip")
#' }
#'
#' @importFrom rlang is_interactive
#' @importFrom cli cli_abort
#' @export
quarto_add_extension <- function(extension = NULL, no_prompt = FALSE) {
  quarto_bin <- find_quarto()

  # This will ask for approval or stop installation
  check_extension_approval(no_prompt, "Quarto extensions", "https://quarto.org/docs/extensions/managing.html")

  args <- c(extension,"--no-prompt")

  quarto_add(args, quarto_bin = quarto_bin, echo = TRUE)

  invisible()
}

quarto_add <- function(args = character(), ...) {
  args <- c("add", args)
  quarto_run(args, ...)
}
