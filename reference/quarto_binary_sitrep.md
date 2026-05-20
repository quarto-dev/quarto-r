# Check configurations for quarto binary used

This function check the configuration for the quarto package R package
to detect a possible difference with version used by RStudio IDE.

## Usage

``` r
quarto_binary_sitrep(verbose = TRUE, debug = FALSE)
```

## Arguments

- verbose:

  if `FALSE`, only return the result of the check.

- debug:

  if `TRUE`, print more information about value set in configurations.

## Value

`TRUE` if this package should be using the same quarto binary as the
RStudio IDE. `FALSE` otherwise if a difference is detected or quarto is
not found. Use `verbose = TRUE` or`debug = TRUE` to get detailed
information.

## Examples

``` r
quarto_binary_sitrep(verbose = FALSE)
#> [1] TRUE
quarto_binary_sitrep(verbose = TRUE)
#> ✔ quarto R package will use /opt/quarto/bin/quarto
#> [1] TRUE
quarto_binary_sitrep(debug = TRUE)
#> ✔ quarto R package will use /opt/quarto/bin/quarto
#> ℹ     It is configured to use the latest version found in the PATH environment variable.
#> [1] TRUE
```
