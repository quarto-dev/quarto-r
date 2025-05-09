#' Remove a Quarto extensions
#'
#' Remove an extension in this folder or project by running `quarto remove`
#'
#' @inheritParams quarto_render
#'
#' @param extension The extension name to remove, as in `quarto remove <extension-name>`.
#'
#' @param no_prompt Do not prompt to confirm approval to download external extension.
#'
#'
#' @return Returns invisibly `TRUE` if the extension was removed, `FALSE` otherwise.
#'
#' @seealso `quarto_add_extension()` and [Quarto Website](https://quarto.org/docs/extensions/managing.html).
#'
#' @examples
#' \dontrun{
#' # Remove an already installed extension
#' quarto_remove_extension("quarto-ext/fontawesome")
#' }
#' @export
quarto_remove_extension <- function(
  extension = NULL,
  no_prompt = FALSE,
  quiet = FALSE,
  quarto_args = NULL
) {
  rlang::check_required(extension)

  installed_extensions <- quarto_list_extensions()
  if (is.null(installed_extensions)) {
    if (!quiet) {
      cli::cli_alert_warning("No extensions installed.")
    }
    return(invisible(FALSE))
  }

  quarto_bin <- find_quarto()

  # This will ask for approval or stop installation
  approval <- check_removal_approval(
    no_prompt,
    extension,
    "https://quarto.org/docs/extensions/managing.html"
  )

  if (approval) {
    args <- c(extension, "--no-prompt", if (quiet) cli_arg_quiet(), quarto_args)
    quarto_remove(args, quarto_bin = quarto_bin, echo = FALSE)
    if (!quiet) {
      cli::cli_alert_success(
        "Extension {.code {extension}} successfully removed."
      )
    }
  }

  invisible(TRUE)
}

quarto_remove <- function(args = character(), ...) {
  quarto_run_what("remove", args = args, ...)
}
