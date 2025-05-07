#' Remove a Quarto extensions
#'
#' Remove an extension in this folder or project by running `quarto remove`
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
#' @inheritParams quarto_render
#'
#' @param extension The extension to remove, either an archive or a GitHub
#'   repository as described in the documentation
#'   <https://quarto.org/docs/extensions/managing.html>.
#'
#' @param no_prompt Do not prompt to confirm approval to download external extension.
#'
#' @examples
#' \dontrun{
#' # Remove an already installed extension
#' quarto_remove_extension("quarto-ext/fontawesome")
#' }
#' @importFrom rlang is_interactive
#' @importFrom cli cli_abort
#' @export
quarto_remove_extension <- function(
  extension = NULL,
  no_prompt = FALSE,
  quiet = FALSE,
  quarto_args = NULL
) {
  rlang::check_required(extension)

  quarto_bin <- find_quarto()

  # This will ask for approval or stop installation
  approval <- check_removal_approval(
    no_prompt,
    extension,
    "https://quarto.org/docs/extensions/managing.html"
  )

  if (approval) {
    args <- c(extension, "--no-prompt", if (quiet) cli_arg_quiet(), quarto_args)
    quarto_remove(args, quarto_bin = quarto_bin, echo = TRUE)
  }

  invisible()
}

quarto_remove <- function(args = character(), ...) {
  quarto_run_what("remove", args = args, ...)
}
