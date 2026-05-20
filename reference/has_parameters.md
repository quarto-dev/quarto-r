# Check if a Quarto document uses parameters

Determines whether a Quarto document uses parameters by examining the
document structure and metadata. This function works with both knitr and
Jupyter engines, using different detection methods for each:

## Usage

``` r
has_parameters(input)
```

## Arguments

- input:

  Path to the Quarto document (.qmd or .ipynb file) to inspect.

## Value

Logical. `TRUE` if the document uses parameters, `FALSE` otherwise.

## Details

- **Knitr engine (.qmd files)**: Checks for a "params" field in the
  document's YAML metadata using
  [`quarto_inspect()`](https://quarto-dev.github.io/quarto-r/reference/quarto_inspect.md)

- **Jupyter engine (.ipynb files)**: Looks for code cells tagged with
  "parameters" following the papermill convention. For .ipynb files, the
  function parses the notebook JSON directly due to limitations in
  `quarto inspect`.

Parameters in Quarto enable creating dynamic, reusable documents. This
function helps identify parameterized documents programmatically, which
is useful for:

- Document processing workflows

- Automated report generation

- Parameter validation before rendering

- Project analysis and organization

For more information about using parameters in Quarto, see
<https://quarto.org/docs/computations/parameters.html>

## Examples

``` r
if (FALSE) { # \dontrun{
# Check if a document uses parameters
has_parameters("my-document.qmd")

# Check a parameterized report
has_parameters("parameterized-report.qmd")

# Check a Jupyter notebook
has_parameters("analysis.ipynb")

# Use in a workflow
if (has_parameters("report.qmd")) {
  message("This document accepts parameters")
}
} # }
```
