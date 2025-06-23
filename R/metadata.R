#' Write YAML Metadata Block for Quarto Documents
#'
#' Creates a YAML metadata block that can be dynamically inserted into Quarto
#' documents from R code chunks. This allows setting metadata values based on
#' R computations, which can then be used with Quarto's conditional content
#' features like `when-meta` and `{{< meta >}}` shortcodes.
#'
#' @param ... Named arguments to include in the metadata block. Names become
#'   the metadata keys and values become the metadata values. These take
#'   precedence over any conflicting keys in `.list`.
#' @param .list Optional list of additional metadata to include. This is useful
#'   when you have metadata stored in a list variable. Keys in `.list` are
#'   overridden by any matching keys provided in `...`.
#'
#' @return A character string containing the formatted YAML metadata block,
#'   wrapped with `knitr::asis_output()` so it renders as raw markdown.
#'   Returns `NULL` invisibly if no metadata is provided.
#'
#' @details
#' The function converts R values to YAML format and wraps them in YAML
#' delimiters (`---`). Logical values are converted to lowercase strings
#' ("true"/"false") to ensure compatibility with Quarto's metadata system.
#'
#' When both `...` and `.list` contain the same key, the value from `...`
#' takes precedence and will override the value from `.list`.
#'
#' If no metadata is provided (empty `...` and `NULL` or empty `.list`),
#' the function returns `NULL` without generating any output.
#'
#' This addresses the limitation where Quarto metadata must be static and
#' cannot be set dynamically from R code during document rendering.
#'
#' @examples
#' \dontrun{
#' # In a Quarto document R chunk:
#' admin <- TRUE
#' user_level <- "advanced"
#'
#' # Set metadata dynamically
#' write_yaml_metadata_block(
#'   admin = admin,
#'   level = user_level,
#'   timestamp = Sys.Date()
#' )
#'
#' # Use with .list parameter
#' metadata_list <- list(version = "1.0", debug = FALSE)
#' write_yaml_metadata_block(.list = metadata_list)
#'
#' # Direct arguments override .list values
#' base_config <- list(theme = "dark", debug = TRUE)
#' write_yaml_metadata_block(
#'   debug = FALSE,  # This overrides debug = TRUE from base_config
#'   author = "John",
#'   .list = base_config
#' )
#'
#' # Then use in Quarto with conditional content:
#' # ::: {.content-visible when-meta="admin"}
#' # Admin-only content here
#' # :::
#' }
#'
#' @export
write_yaml_metadata_block <- function(..., .list = NULL) {
  meta <- list(...)
  if (!is.null(.list)) {
    meta <- merge_list(.list, list(...))
  }
  if (length(meta) == 0) {
    return()
  }
  res <- as_yaml(meta)
  yaml_block <- paste0("---\n", res, "---\n")
  knitr::asis_output(yaml_block)
}
