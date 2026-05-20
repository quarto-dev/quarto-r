# YAML character handler for YAML 1.1 to 1.2 compatibility

This handler bridges the gap between R's yaml package (YAML 1.1) and
js-yaml (YAML 1.2) by quoting strings with leading zeros that would be
misinterpreted as octal numbers.

## Usage

``` r
yaml_character_handler(x)
```

## Arguments

- x:

  A character vector

## Value

The input with quoted attributes applied where needed

## Details

According to YAML 1.1 spec, octal integers are `0o[0-7]+`. The R yaml
package only quotes valid octals (containing only digits 0-7), but
js-yaml attempts to parse ANY leading zero string as octal, causing data
corruption for invalid octals like "029" → 29.

## See also

[YAML 1.1 int spec](https://yaml.org/type/int.html)
