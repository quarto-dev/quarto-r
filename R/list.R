#' List Installed Quarto extensions
#'
#' List Quarto Extensions in this folder or project by running `quarto list`
#'
#' @return A data frame with the installed extensions or NULL (invisibly) if no extensions are installed.
#'
#' @examples
#' \dontrun{
#' # List Quarto Extensions in this folder or project
#' quarto_list_extensions()
#' }
#'
#' @export
quarto_list_extensions <- function() {
  quarto_bin <- find_quarto()

  # quarto list extensions --quiet will return nothing so we need to prevent that.
  args <- c("extensions")
  x <- quarto_list(args, quarto_bin = quarto_bin, echo = FALSE)
  # Clean the stderr output to remove extra spaces and ensure consistent formatting
  stderr_cleaned <- gsub("\\s+$", "", x$stderr)
  # Quarto CLI prepends a "Quarto version: X.Y.Z" line to stderr when log level
  # is DEBUG (auto-enabled in GHA debug mode). Strip it so read.table() can use
  # the real header row. See https://github.com/quarto-dev/quarto-cli/issues/14532.
  stderr_cleaned <- sub("^Quarto version:[^\n]*\n", "", stderr_cleaned)
  if (grepl("No extensions are installed", stderr_cleaned)) {
    invisible()
  } else {
    df <- utils::read.table(
      text = stderr_cleaned,
      header = TRUE,
      fill = TRUE,
      sep = "",
      stringsAsFactors = FALSE
    )
    df[order(df$Id), ]
  }
}

quarto_list <- function(args = character(), ...) {
  quarto_run_what("list", args = args, ...)
}
