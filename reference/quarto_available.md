# Check if quarto is available and version meet some requirements

This function allows to test if Quarto is available and meets version
requirement, a min, max or in between requirement.

## Usage

``` r
quarto_available(min = NULL, max = NULL, error = FALSE)
```

## Arguments

- min:

  Minimum version expected.

- max:

  Maximum version expected

- error:

  If `TRUE`, will throw an error if Quarto is not available or does not
  meet the requirement. Default is `FALSE`.

## Value

logical. `TRUE` if requirement is met, `FALSE` otherwise.

## Details

If `min` and `max` are provided, this will check if Quarto version is
in-between two versions. If non is provided (keeping the default `NULL`
for both), it will just check for Quarto availability version and return
`FALSE` if not found.

## Examples

``` r
# Is there an active version available ?
quarto_available()
#> [1] TRUE
# check for a minimum requirement
quarto_available(min = "1.5")
#> [1] TRUE
# check for a maximum version
quarto_available(max = "1.6")
#> [1] FALSE
# only returns TRUE if Pandoc version is between two bounds
quarto_available(min = "1.4", max = "1.6")
#> [1] FALSE
```
