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
#' ## YAML 1.2 Compatibility:
#' To ensure compatibility with Quarto's YAML 1.2 parser (js-yaml), the function
#' automatically handles two key differences between R's yaml package (YAML 1.1)
#' and YAML 1.2:
#'
#' ### Boolean values:
#' R logical values (`TRUE`/`FALSE`) are converted to lowercase
#' YAML 1.2 format (`true`/`false`) using [yaml::verbatim_logical()]. This prevents
#' YAML 1.1 boolean representations like `yes`/`no` from being used.
#'
#' ### String quoting:
#' Strings with leading zeros that contain digits 8 or 9 (like `"029"`, `"089"`)
#' are automatically quoted to prevent them from being parsed as octal numbers,
#' which would result in data corruption (e.g., `"029"` becoming `29`).
#' Valid octal numbers containing only digits 0-7 (like `"0123"`) are handled
#' by the underlying \pkg{yaml} package.
#'
#' For manual control over string quoting behavior, use [yaml_quote_string()].
#'
#' ## Quarto Usage:
#' To use this function in a Quarto document, create an R code chunk with
#' the `output: asis` option:
#'
#' ```
#' ```{r}
#' #| output: asis
#' write_yaml_metadata_block(admin = TRUE, version = "1.0")
#' ```
#' ```
#'
#' Without the `output: asis` option, the YAML metadata block will be
#' displayed as text rather than processed as metadata by Quarto.
#'
#' @inherit yaml_character_handler seealso
#'
#' @examples
#' \dontrun{
#' # In a Quarto document R chunk with `#| output: asis`:
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
#' # Strings with leading zeros are automatically quoted for YAML 1.2 compatibility
#' write_yaml_metadata_block(
#'   zip_code = "029",    # Automatically quoted as "029"
#'   build_id = "0123"    # Quoted by yaml package (valid octal)
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
#' @seealso [yaml_quote_string()] for explicitly controlling which strings are quoted
#'   in YAML output when you encounter edge cases that need manual handling.
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
  yaml_block <- as_yaml_block(meta)
  knitr::asis_output(yaml_block)
}
