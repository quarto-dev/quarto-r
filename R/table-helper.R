#' Create Quarto Markdown HTML Elements for Tables
#'
#' Functions to wrap content in HTML spans or divs with data-qmd attributes for
#' Quarto processing within HTML tables. These functions are specifically designed
#' for use with HTML table packages like kableExtra, gt, or DT where you need
#' Quarto to process markdown content within table cells.
#'
#' @details
#' These functions create HTML elements with `data-qmd` or `data-qmd-base64`
#' attributes that Quarto processes during document rendering. The base64
#' encoding is recommended for content with special characters, quotes, or
#' complex formatting.
#'
#' Available functions:
#'
#' * `tbl_qmd_span()` and `tbl_qmd_div()` are the main functions with encoding options
#' * `tbl_qmd_span_base64()` and `tbl_qmd_div_base64()` explicitly use base64 encoding
#' * `tbl_qmd_span_raw()` and `tbl_qmd_div_raw()` explicitly use raw encoding
#'
#' This feature requires Quarto version 1.3 or higher with HTML format outputs.
#' For more information, see <https://quarto.org/docs/authoring/tables.html#html-tables>.
#'
#' @param content Character string of content to wrap. This can include Markdown,
#'   LaTeX math, and Quarto shortcodes.
#' @param display Optional display text (if different from content). Useful for
#'   fallback text when Quarto processing is not available or for better
#'   accessibility.
#' @param use_base64 Logical, whether to base64 encode the content (recommended
#'   for complex content with special characters or when content includes quotes)
#'
#' @return Character string containing the HTML element with appropriate data-qmd attributes
#'
#' @examples
#' # Basic span usage in table cells
#' tbl_qmd_span("**bold text**")
#' tbl_qmd_span("$\\alpha + \\beta$", display = "Greek formula")
#'
#' # Basic div usage in table cells
#' tbl_qmd_div("## Section Title\n\nContent here")
#' tbl_qmd_div("{{< video https://example.com >}}", display = "[Video content]")
#'
#' # Explicit encoding choices
#' tbl_qmd_span_base64("Complex $\\LaTeX$ content")
#' tbl_qmd_span_raw("Simple text")
#'
#' # Use with different HTML table packages
#' \dontrun{
#' # With kableExtra
#' library(kableExtra)
#' df <- data.frame(
#'   math = c(tbl_qmd_span("$x^2$"), tbl_qmd_span("$\\sum_{i=1}^n x_i$")),
#'   text = c(tbl_qmd_span("**Important**", "bold"), tbl_qmd_span("`code`", "code"))
#' )
#' kbl(df, format = "html", escape = FALSE) |> kable_styling()
#' }
#' @name tbl_qmd_elements
NULL


.validate_tbl_qmd_input <- function(
  content,
  display = NULL,
  call = rlang::caller_env()
) {
  if (!is.character(content) || length(content) != 1) {
    cli::cli_abort("'content' must be a single character string", call = call)
  }

  if (!is.null(display) && (!is.character(display) || length(display) != 1)) {
    cli::cli_abort(
      "'display' must be NULL or a single character string",
      call = call
    )
  }

  invisible(TRUE)
}

#' @inheritParams tbl_qmd_elements
#' @param class Optional CSS class(es) to add to the element. While this works for
#'   both span and div elements, it's more commonly used with div elements.
#' @param attrs Named list of additional HTML attributes to add to the element.
#'   For example: `list(id = "my-element", title = "Tooltip text")`
#' @noRd
.tbl_qmd_element <- function(
  tag,
  content,
  display,
  use_base64,
  class = NULL,
  attrs = NULL
) {
  .validate_tbl_qmd_input(content, display)

  if (is.null(display)) {
    display <- content
  }

  if (use_base64) {
    encoded_content <- xfun::base64_encode(charToRaw(content))
    attr_list <- list("data-qmd-base64" = encoded_content)
  } else {
    attr_list <- list("data-qmd" = content)
  }

  # Add class if provided
  if (!is.null(class)) {
    attr_list$class <- class
  }

  # Add any additional attributes
  if (!is.null(attrs) && is.list(attrs) && length(attrs) > 0) {
    attr_list <- c(attr_list, attrs)
  }
  # Create HTML element using htmltools
  html_element <- if (tag == "div") {
    do.call(htmltools::div, c(list(display, .noWS = "outside"), attr_list))
  } else {
    do.call(htmltools::span, c(list(display, .noWS = "outside"), attr_list))
  }

  # Convert to character string
  as.character(html_element)
}

#' @rdname tbl_qmd_elements
#' @export
tbl_qmd_span <- function(
  content,
  display = NULL,
  use_base64 = TRUE
) {
  .tbl_qmd_element("span", content, display, use_base64)
}

#' @rdname tbl_qmd_elements
#' @export
tbl_qmd_div <- function(
  content,
  display = NULL,
  use_base64 = TRUE
) {
  .tbl_qmd_element("div", content, display, use_base64)
}
#' @rdname tbl_qmd_elements
#' @export
tbl_qmd_span_base64 <- function(
  content,
  display = NULL
) {
  tbl_qmd_span(
    content,
    display,
    use_base64 = TRUE
  )
}

#' @rdname tbl_qmd_elements
#' @export
tbl_qmd_div_base64 <- function(
  content,
  display = NULL
) {
  tbl_qmd_div(content, display, use_base64 = TRUE)
}

#' @rdname tbl_qmd_elements
#' @export
tbl_qmd_span_raw <- function(
  content,
  display = NULL
) {
  tbl_qmd_span(
    content,
    display,
    use_base64 = FALSE
  )
}

#' @rdname tbl_qmd_elements
#' @export
tbl_qmd_div_raw <- function(
  content,
  display = NULL
) {
  tbl_qmd_div(
    content,
    display,
    use_base64 = FALSE
  )
}
