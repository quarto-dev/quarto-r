# Add spin preamble to R script

Adds a minimal spin preamble to an R script file if one doesn't already
exist. The preamble includes a title derived from the filename and is
formatted as a YAML block suitable preprended with `#'` for
[`knitr::spin()`](https://rdrr.io/pkg/knitr/man/spin.html).

## Usage

``` r
add_spin_preamble(script, title = NULL, preamble = NULL, quiet = FALSE)
```

## Arguments

- script:

  Path to the R script file

- title:

  Custom title for the preamble. If provided, overrides any title in the
  `preamble` list. If NULL, uses `preamble$title` or filename as
  fallback.

- preamble:

  Named list of YAML metadata to include in preamble. The `title`
  parameter takes precedence over `preamble$title` if both are provided.

- quiet:

  If `TRUE`, suppresses messages and warnings.

## Value

Invisibly returns the script path if modified, otherwise invisible NULL

## Details

This is useful to prepare R scripts for use with Quarto Script rendering
support. See
<https://quarto.org/docs/computations/render-scripts.html#knitr>

## Preamble format

For a script named `analysis.R`, the function adds this preamble by
default:

    #' ---
    #' title: analysis
    #' ---
    #'

    # Original script content starts here

This is the minimal preamble required for Quarto Script rendering, so
that [Engine
Bindings](https://quarto.org/docs/computations/execution-options.html#engine-binding)
works.

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage with default title
add_spin_preamble("analysis.R")

# Custom title
add_spin_preamble("analysis.R", title = "My Analysis")

# Custom preamble with multiple fields
add_spin_preamble("analysis.R", preamble = list(
  title = "Advanced Analysis",
  author = "John Doe",
  date = Sys.Date(),
  format = "html"
))

# Title parameter overrides preamble title
add_spin_preamble("analysis.R",
  title = "Final Title",  # This takes precedence
  preamble = list(
    title = "Ignored Title",
    author = "John Doe"
  )
)
} # }
```
