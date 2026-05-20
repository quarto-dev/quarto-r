# Remove a Quarto extensions

Remove an extension in this folder or project by running `quarto remove`

## Usage

``` r
quarto_remove_extension(
  extension = NULL,
  no_prompt = FALSE,
  quiet = FALSE,
  quarto_args = NULL
)
```

## Arguments

- extension:

  The extension name to remove, as in `quarto remove <extension-name>`.

- no_prompt:

  Do not prompt to confirm approval to download external extension.

- quiet:

  Suppress warning and other messages, from R and also Quarto CLI (i.e
  `--quiet` is passed as command line).

  `quarto.quiet` R option or `R_QUARTO_QUIET` environment variable can
  be used to globally override a function call (This can be useful to
  debug tool that calls `quarto_*` functions directly).

  On Github Actions, it will always be `quiet = FALSE`.

- quarto_args:

  Character vector of other `quarto` CLI arguments to append to the
  Quarto command executed by this function. This is mainly intended for
  advanced usage and useful for CLI arguments which are not yet mirrored
  in a dedicated parameter of this R function. See
  `quarto render --help` for options.

## Value

Returns invisibly `TRUE` if the extension was removed, `FALSE`
otherwise.

## See also

[`quarto_add_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_add_extension.md)
and [Quarto Website](https://quarto.org/docs/extensions/managing.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# Remove an already installed extension
quarto_remove_extension("quarto-ext/fontawesome")
} # }
```
