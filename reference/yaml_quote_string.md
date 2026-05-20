# Add quoted attribute to strings for YAML output

This function allows users to explicitly mark strings that should be
quoted in YAML output, giving full control over quoting behavior.

## Usage

``` r
yaml_quote_string(x)
```

## Arguments

- x:

  A character vector or single string

## Value

The input with quoted attributes applied

## Details

This is particularly useful for special values that might be
misinterpreted as yaml uses YAML 1.1 and Quarto expects YAML 1.2.

The `quoted` attribute is a convention used by
[`yaml::as.yaml()`](https://yaml.r-lib.org/reference/as.yaml.html)

## Examples

``` r
yaml::as.yaml(list(id = yaml_quote_string("1.0")))
#> [1] "id: \"1.0\"\n"
yaml::as.yaml(list(id = "1.0"))
#> [1] "id: '1.0'\n"
```
