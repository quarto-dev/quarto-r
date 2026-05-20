# Inspect Quarto Input File or Project

Inspect a Quarto project or input path. Inspecting a project returns its
config and engines. Inspecting an input path return its formats, engine,
and dependent resources.

## Usage

``` r
quarto_inspect(input = ".", profile = NULL, quiet = FALSE, quarto_args = NULL)
```

## Arguments

- input:

  The input file or project directory to inspect.

- profile:

  [Quarto project
  profile(s)](https://quarto.org/docs/projects/profiles.html) to use.
  Either a character vector of profile names or `NULL` to use the
  default profile.

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

Named list. For input files, the list contains the elements `quarto`,
`engines`, `formats`, `resources`, `fileInformation` plus `project` if
the file is part of a Quarto project. For projects, the list contains
the elements `quarto`, `dir`, `engines`, `config` and `files`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Inspect input file file
quarto_inspect("notebook.Rmd")

# Inspect project
quarto_inspect("myproject")

# Inspect project's advanced profile
quarto_inspect(
  input = "myproject",
  profile = "advanced"
)
} # }
```
