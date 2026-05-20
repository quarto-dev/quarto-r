# Create Quarto Markdown HTML Elements for Tables

Functions to wrap content in HTML spans or divs with data-qmd attributes
for Quarto processing within HTML tables. These functions are
specifically designed for use with HTML table packages like kableExtra,
gt, or DT where you need Quarto to process markdown content within table
cells.

## Usage

``` r
tbl_qmd_span(content, display = NULL, use_base64 = TRUE)

tbl_qmd_div(content, display = NULL, use_base64 = TRUE)

tbl_qmd_span_base64(content, display = NULL)

tbl_qmd_div_base64(content, display = NULL)

tbl_qmd_span_raw(content, display = NULL)

tbl_qmd_div_raw(content, display = NULL)
```

## Arguments

- content:

  Character string of content to wrap. This can include Markdown, LaTeX
  math, and Quarto shortcodes.

- display:

  Optional display text (if different from content). Useful for fallback
  text when Quarto processing is not available or for better
  accessibility.

- use_base64:

  Logical, whether to base64 encode the content (recommended for complex
  content with special characters or when content includes quotes)

## Value

Character string containing the HTML element with appropriate data-qmd
attributes

## Details

These functions create HTML elements with `data-qmd` or
`data-qmd-base64` attributes that Quarto processes during document
rendering. The base64 encoding is recommended for content with special
characters, quotes, or complex formatting.

Available functions:

- `tbl_qmd_span()` and `tbl_qmd_div()` are the main functions with
  encoding options

- `tbl_qmd_span_base64()` and `tbl_qmd_div_base64()` explicitly use
  base64 encoding

- `tbl_qmd_span_raw()` and `tbl_qmd_div_raw()` explicitly use raw
  encoding

This feature requires Quarto version 1.3 or higher with HTML format
outputs. For more information, see
<https://quarto.org/docs/authoring/tables.html#html-tables>.

## Examples

``` r
# Basic span usage in table cells
tbl_qmd_span("**bold text**")
#> [1] "<span data-qmd-base64=\"Kipib2xkIHRleHQqKg==\">**bold text**</span>"
tbl_qmd_span("$\\alpha + \\beta$", display = "Greek formula")
#> [1] "<span data-qmd-base64=\"JFxhbHBoYSArIFxiZXRhJA==\">Greek formula</span>"

# Basic div usage in table cells
tbl_qmd_div("## Section Title\n\nContent here")
#> [1] "<div data-qmd-base64=\"IyMgU2VjdGlvbiBUaXRsZQoKQ29udGVudCBoZXJl\">## Section Title\n\nContent here</div>"
tbl_qmd_div("{{< video https://example.com >}}", display = "[Video content]")
#> [1] "<div data-qmd-base64=\"e3s8IHZpZGVvIGh0dHBzOi8vZXhhbXBsZS5jb20gPn19\">[Video content]</div>"

# Explicit encoding choices
tbl_qmd_span_base64("Complex $\\LaTeX$ content")
#> [1] "<span data-qmd-base64=\"Q29tcGxleCAkXExhVGVYJCBjb250ZW50\">Complex $\\LaTeX$ content</span>"
tbl_qmd_span_raw("Simple text")
#> [1] "<span data-qmd=\"Simple text\">Simple text</span>"

# Use with different HTML table packages
if (FALSE) { # \dontrun{
# With kableExtra
library(kableExtra)
df <- data.frame(
  math = c(tbl_qmd_span("$x^2$"), tbl_qmd_span("$\\sum_{i=1}^n x_i$")),
  text = c(tbl_qmd_span("**Important**", "bold"), tbl_qmd_span("`code`", "code"))
)
kbl(df, format = "html", escape = FALSE) |> kable_styling()
} # }
```
