# Check quarto version

Determine the specific version of quarto binary found by
[`quarto_path()`](https://quarto-dev.github.io/quarto-r/reference/quarto_path.md).
If it returns `99.9.9` then it means you are using a dev version.

## Usage

``` r
quarto_version()
```

## Value

a [`numeric_version`](https://rdrr.io/r/base/numeric_version.html) with
the quarto version found

## See also

[`quarto_available()`](https://quarto-dev.github.io/quarto-r/reference/quarto_available.md)
to check if the version meets some requirements.
