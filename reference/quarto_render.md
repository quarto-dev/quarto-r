# Render Markdown

Render the input file to the specified output format using quarto. If
the input requires computations (e.g. for Rmd or Jupyter files) then
those computations are performed before rendering.

## Usage

``` r
quarto_render(
  input = NULL,
  output_format = NULL,
  output_file = NULL,
  execute = TRUE,
  execute_params = NULL,
  execute_dir = NULL,
  execute_daemon = NULL,
  execute_daemon_restart = FALSE,
  execute_debug = FALSE,
  use_freezer = FALSE,
  cache = NULL,
  cache_refresh = FALSE,
  metadata = NULL,
  metadata_file = NULL,
  debug = FALSE,
  quiet = FALSE,
  profile = NULL,
  quarto_args = NULL,
  pandoc_args = NULL,
  libpaths = .libPaths(),
  as_job = getOption("quarto.render_as_job", "auto")
)
```

## Arguments

- input:

  The input file or project directory to be rendered (defaults to
  rendering the project in the current working directory).

- output_format:

  Target output format (defaults to `"html"`). The option `"all"` will
  render all formats defined within the file or project.

- output_file:

  Base name for single-file output (e.g. PDF, ePub, MS Word). This sets
  the `output-file` Quarto metadata. If `NULL`, the output filename will
  be based on the input filename.

- execute:

  Whether to execute embedded code chunks.

- execute_params:

  A list of named parameters that override custom params specified
  within the YAML front-matter.

- execute_dir:

  The working directory in which to execute embedded code chunks.

- execute_daemon:

  Keep Jupyter kernel alive (defaults to 300 seconds). Note this option
  is only applicable for rendering Jupyter notebooks or Jupyter
  markdown.

- execute_daemon_restart:

  Restart keepalive Jupyter kernel before render. Note this option is
  only applicable for rendering Jupyter notebooks or Jupyter markdown.

- execute_debug:

  Show debug output for Jupyter kernel.

- use_freezer:

  Force use of frozen computations for an incremental file render.

- cache:

  Cache execution output (uses knitr cache and jupyter-cache
  respectively for Rmd and Jupyter input files).

- cache_refresh:

  Force refresh of execution cache.

- metadata:

  An optional named list used to override YAML metadata. It will be
  passed as a YAML file to `--metadata-file` CLI flag. This will be
  merged over `metadata-file` options if both are specified.

- metadata_file:

  A yaml file passed to `--metadata-file` CLI flags to override
  metadata. This will be merged with `metadata` if both are specified,
  with low precedence on `metadata` options.

- debug:

  Leave intermediate files in place after render.

- quiet:

  Suppress warning and other messages, from R and also Quarto CLI (i.e
  `--quiet` is passed as command line).

  `quarto.quiet` R option or `R_QUARTO_QUIET` environment variable can
  be used to globally override a function call (This can be useful to
  debug tool that calls `quarto_*` functions directly).

  On Github Actions, it will always be `quiet = FALSE`.

- profile:

  [Quarto project
  profile(s)](https://quarto.org/docs/projects/profiles.html) to use.
  Either a character vector of profile names or `NULL` to use the
  default profile.

- quarto_args:

  Character vector of other `quarto` CLI arguments to append to the
  Quarto command executed by this function. This is mainly intended for
  advanced usage and useful for CLI arguments which are not yet mirrored
  in a dedicated parameter of this R function. See
  `quarto render --help` for options.

- pandoc_args:

  Additional command line arguments to pass on to Pandoc.

- libpaths:

  A character vector of library paths to use for the R session run by
  Quarto. If `NULL`, no library paths will be pass to quarto subprocess
  and defaults R one will be used. Setting
  `options(quarto.use_libpaths = FALSE)` will disable this behavior and
  never pass library paths to quarto subprocess.

- as_job:

  Render as an RStudio background job. Default is `"auto"`, which will
  render individual documents normally and projects as background jobs.
  Use the `quarto.render_as_job` R option to control the default
  globally.

## Value

Invisibly returns `NULL`. The function is called for its side effect of
rendering the specified document or project.

## Examples

``` r
if (FALSE) { # \dontrun{
# Render R Markdown
quarto_render("notebook.Rmd")
quarto_render("notebook.Rmd", output_format = "pdf")

# Render Jupyter Notebook
quarto_render("notebook.ipynb")

# Render Jupyter Markdown
quarto_render("notebook.md")

# Override metadata
quarto_render("notebook.Rmd", metadata = list(lang = "fr", execute = list(echo = FALSE)))
} # }
```
