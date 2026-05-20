# Check is a directory is using quarto

This function will check if a directory is using quarto by looking for

- `_quarto.yml` at its root

- at least one `.qmd` file in the directory

## Usage

``` r
is_using_quarto(dir = ".", verbose = FALSE)
```

## Arguments

- dir:

  The directory to check

- verbose:

  print message about the result of the check

## Examples

``` r
dir.create(tmpdir <- tempfile())
is_using_quarto(tmpdir)
#> [1] FALSE
file.create(file.path(tmpdir, "_quarto.yml"))
#> [1] TRUE
is_using_quarto(tmpdir)
#> [1] TRUE
unlink(tmpdir, recursive = TRUE)
```
