#' Update a Quarto extensions
#'
#' Update an extension to this folder or project by running `quarto update`
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
#' @param extension The extension to update, either by its name (i.e ` quarto update extension <gh-org>/<gh-repo>`), an archive (` quarto update extension <path-to-zip>`) or a url (`quarto update extension <url>`).
#'
#' @param no_prompt Do not prompt to confirm approval to download external extension. Setting `no_prompt = FALSE` means [Extension Trust](#extension-trust) is accepted.
#'
#' @seealso [quarto_add_extension()], [quarto_remove_extension()], and [Quarto website](https://quarto.org/docs/extensions/managing.html).
#'
#' @return Returns invisibly `TRUE` if the extension was updated, `FALSE` otherwise.
#'
#' @examples
#' \dontrun{
#' # Update a template and set up a draft document from a GitHub repository
#' quarto_update_extension("quarto-ext/fontawesome")
#'
#' # Update a template and set up a draft document from a ZIP archive
#' quarto_update_extension("https://github.com/quarto-ext/fontawesome/archive/refs/heads/main.zip")
#' }
#' @export
quarto_update_extension <- function(
  extension = NULL,
  no_prompt = FALSE,
  quiet = FALSE,
  quarto_args = NULL
) {
  rlang::check_required(extension)

  quarto_bin <- find_quarto()

  # This will ask for approval or stop installation
  approval <- check_extension_approval(
    no_prompt,
    "Quarto extension",
    "https://quarto.org/docs/extensions/managing.html"
  )

  if (!approval) {
    return(invisible(FALSE))
  }

  args <- c(extension, "--no-prompt", if (quiet) cli_arg_quiet(), quarto_args)
  quarto_update(args, quarto_bin = quarto_bin, echo = TRUE)
  if (!quiet) {
    cli::cli_inform("Extension {.code {extension}} updated.")
  }
  invisible(TRUE)
}

quarto_update <- function(args = character(), ...) {
  quarto_run_what("update", args = args, ...)
}
