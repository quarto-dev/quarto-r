#' List Installed Quarto extensions
#'
#' List Quarto Extensions in this folder or project by running `quarto list`
#'
#' @inheritParams quarto_render
#'
#' @examples
#' \dontrun{
#' # List Quarto Extensions in this folder or project
#' quarto_list_extensions()
#' }
#'
#' @importFrom rlang is_interactive
#' @importFrom cli cli_abort
#' @importFrom utils read.table
#' @export
quarto_list_extensions <- function(quiet = FALSE, quarto_args = NULL) {
  quarto_bin <- find_quarto()

  args <- c("extensions", if (quiet) cli_arg_quiet(), quarto_args)
  x <- quarto_list(args, quarto_bin = quarto_bin, echo = TRUE)
  # Clean the stderr output to remove extra spaces and ensure consistent formatting
  stderr_cleaned <- gsub("\\s+$", "", x$stderr)
  if (grepl("No extensions are installed", stderr_cleaned)) {
    invisible()
  } else {
    invisible(utils::read.table(
      text = stderr_cleaned,
      header = TRUE,
      fill = TRUE,
      sep = "",
      stringsAsFactors = FALSE
    ))
  }
}

quarto_list <- function(args = character(), ...) {
  quarto_run_what("list", args = args, ...)
}
