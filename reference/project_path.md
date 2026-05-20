# Get path relative to project root (Quarto-aware)

**\[experimental\]**

This function constructs file paths relative to the project root when
running in a Quarto context (using `QUARTO_PROJECT_ROOT` or
`QUARTO_PROJECT_DIR` environment variables), or falls back to
intelligent project root detection when not in a Quarto context.

It is experimental and subject to change in future releases. The
automatic project root detection may not work reliably in all contexts,
especially when projects have complex directory structures or when
running in non-standard environments. For a more explicit and
potentially more robust approach, consider using `here::i_am()` to
declare your project structure, followed by `here::here()` for path
construction. See examples for comparison.

## Usage

``` r
project_path(..., root = NULL)
```

## Arguments

- ...:

  Character vectors of path components to be joined

- root:

  Project root directory. If `NULL` (default), automatic detection is
  used following the hierarchy described above

## Value

A character vector of the normalized file path relative to the project
root.

## Details

The function uses the following fallback hierarchy to determine the
project root:

- Quarto environment variables set during Quarto commands (e.g.,
  `quarto render`):

  - `QUARTO_PROJECT_ROOT` environment variable (set by Quarto commands)

  - `QUARTO_PROJECT_DIR` environment variable (alternative Quarto
    variable)

- Fallback to intelligent project root detection using
  [`xfun::proj_root()`](https://rdrr.io/pkg/xfun/man/proj_root.html) for
  interactive sessions:

  - `_quarto.yml` or `_quarto.yaml` (Quarto project files)

  - `DESCRIPTION` file with `Package:` field (R package or Project)

  - `.Rproj` files with `Version:` field (RStudio projects)

Last fallback is the current working directory if no project root can be
determined. A warning is issued to alert users that behavior may differ
between interactive use and Quarto rendering, as in this case the
computed path may be wrong.

## Use in Quarto document cells

This function is particularly useful in Quarto document cells where you
want to use a path relative to the project root dynamically during
rendering.

    ```{r}`r ''`
     # Get a csv path from data directory in the Quarto project root
     data <- project_path("data", "my_data.csv")
    ```

## See also

- `here::here()` and `here::i_am()` for a similar function that works
  with R projects

- [`find_project_root()`](https://quarto-dev.github.io/quarto-r/reference/find_project_root.md)
  to search for Quarto Project configuration in parents directories

- [`get_running_project_root()`](https://quarto-dev.github.io/quarto-r/reference/get_running_project_root.md)
  for detecting the project root in Quarto commands

- [`xfun::from_root()`](https://rdrr.io/pkg/xfun/man/from_root.html) for
  the underlying path construction

- [`xfun::proj_root()`](https://rdrr.io/pkg/xfun/man/proj_root.html) for
  project root detection logic

## Examples

``` r
if (FALSE) { # \dontrun{
# Create a dummy Quarto project structure for example
tmpdir <- tempfile("quarto_project")
dir.create(tmpdir)
quarto::quarto_create_project(
  'test project', type = 'blog',
  dir = tmpdir, no_prompt = TRUE, quiet = TRUE
)
project_dir <- file.path(tmpdir, "test project")

# Simulate working within a blog post
xfun::in_dir(
  dir = file.path(project_dir, "posts", "welcome"), {

  # Reference a data file from project root
  # ../../data/my_data.csv
  quarto::project_path("data", "my_data.csv")

  # Reference a script from project root
  # ../../R/analysis.R
  quarto::project_path("R", "analysis.R")

  # Explicitly specify root (overrides automatic detection)
  # ../../data/file.csv
  quarto::project_path("data", "file.csv", root = "../..")

  # Alternative approach using here::i_am() (potentially more robust)
  # This approach requires you to declare where you are in the project:
  if (requireNamespace("here", quietly = TRUE)) {
    # Declare that this document is in the project root or subdirectory
    here::i_am("posts/welcome/index.qmd")

    # Now here::here() will work reliably from the project root
    here::here("data", "my_data.csv")
    here::here("R", "analysis.R")
  }
})

} # }
```
