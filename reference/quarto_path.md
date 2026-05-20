# Path to the quarto binary

Determine the path to the quarto binary. Uses `QUARTO_PATH` environment
variable if defined, otherwise uses
[`Sys.which()`](https://rdrr.io/r/base/Sys.which.html).

## Usage

``` r
quarto_path(normalize = TRUE)
```

## Arguments

- normalize:

  If `TRUE` (default), normalize the path using
  [`base::normalizePath()`](https://rdrr.io/r/base/normalizePath.html).

## Value

Path to quarto binary (or `NULL` if not found)

## See also

[`quarto_version()`](https://quarto-dev.github.io/quarto-r/reference/quarto_version.md)
to check the version of the binary found,
[`quarto_available()`](https://quarto-dev.github.io/quarto-r/reference/quarto_available.md)
to check if Quarto CLI is available and meets some requirements.
