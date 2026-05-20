# Get the root of the currently running Quarto project

This function is to be used inside cells and will return the project
root when doing
[`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md)
by detecting Quarto project environment variables.

## Usage

``` r
get_running_project_root()
```

## Value

Character Quarto project root path from set environment variables.

## Details

Quarto sets `QUARTO_PROJECT_ROOT` and `QUARTO_PROJECT_DIR` environment
variables when executing commands within a Quarto project context (e.g.,
`quarto render`, `quarto preview`). This function detects their
presence.

Note that this function will return `NULL` when running code
interactively in an IDE (even within a Quarto project directory), as
these specific environment variables are only set during Quarto command
execution.

## Use in Quarto document cells

This function is particularly useful in Quarto document cells where you
want to get the project root path dynamically during rendering. Cell
example:

    ```{r}`r ''`
     # Get the project root path
     project_root <- get_running_project_root()
    ```

## See also

- [`find_project_root()`](https://quarto-dev.github.io/quarto-r/reference/find_project_root.md)
  for finding the Quarto project root directory

- [`project_path()`](https://quarto-dev.github.io/quarto-r/reference/project_path.md)
  for constructing paths relative to the project root

## Examples

``` r
if (FALSE) { # \dontrun{
get_running_project_root()
} # }
```
