# Update a Quarto extensions

Update an extension to this folder or project by running `quarto update`

## Usage

``` r
quarto_update_extension(
  extension = NULL,
  no_prompt = FALSE,
  quiet = FALSE,
  quarto_args = NULL
)
```

## Arguments

- extension:

  The extension to update, either by its name (i.e
  ` quarto update extension <gh-org>/<gh-repo>`), an archive
  (` quarto update extension <path-to-zip>`) or a url
  (`quarto update extension <url>`).

- no_prompt:

  Do not prompt to confirm approval to download external extension.
  Setting `no_prompt = FALSE` means [Extension Trust](#extension-trust)
  is accepted.

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

Returns invisibly `TRUE` if the extension was updated, `FALSE`
otherwise.

## Extension Trust

Quarto extensions may execute code when documents are rendered.
Therefore, if you do not trust the author of an extension, we recommend
that you do not install or use the extension. By default
`no_prompt = FALSE` which means that the function will ask for explicit
approval when used interactively, or disallow installation.

## See also

[`quarto_add_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_add_extension.md),
[`quarto_remove_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_remove_extension.md),
and [Quarto website](https://quarto.org/docs/extensions/managing.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# Update a template and set up a draft document from a GitHub repository
quarto_update_extension("quarto-ext/fontawesome")

# Update a template and set up a draft document from a ZIP archive
quarto_update_extension("https://github.com/quarto-ext/fontawesome/archive/refs/heads/main.zip")
} # }
```
