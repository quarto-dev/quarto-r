# Log debug information to a configurable file

This function logs messages to a file only when in debug mode to help
diagnose issues with Quarto vignettes in **pkgdown** and other contexts.

## Usage

``` r
quarto_log(
  ...,
  file = NULL,
  append = TRUE,
  timestamp = TRUE,
  prefix = "DEBUG: "
)
```

## Arguments

- ...:

  Messages to log (will be concatenated)

- file:

  Path to log file. If NULL, uses `get_log_file()` to determine the
  file. Default will be `./quarto-r-debug.log` if no configuration is
  found.

- append:

  Logical. Should the messages be appended to the file? Default TRUE.

- timestamp:

  Logical. Should a timestamp be added? Default TRUE.

- prefix:

  Character. Prefix to add before each log entry. Default "DEBUG: ".

## Value

Invisibly returns TRUE if logging occurred, FALSE otherwise

## Details

Debug mode will be enabled automatically when debugging Github Actions
workflows, or when Quarto CLI's environment variable `QUARTO_LOG_LEVEL`
is set to `DEBUG`.

## Configuration

**Enable debugging messages:**

- Set `quarto.log.debug = TRUE` (or `R_QUARTO_LOG_DEBUG = TRUE`
  environment variable)

**Change log file path:**

- Set `quarto.log.file` to change the file path (or `R_QUARTO_LOG_FILE`
  environment variable)

- Default will be `./quarto-r-debug.log`

**Automatic debug mode:**

- Debug mode will be on automatically when debugging Github Actions
  workflows

- When Quarto CLI's environment variable `QUARTO_LOG_LEVEL` is set to
  `DEBUG`

## Examples

``` r
if (FALSE) { # \dontrun{
# Set log file via environment variable
Sys.setenv(R_QUARTO_LOG_FILE = "~/quarto-debug.log")

# Or via option
options(quarto.log.file = "~/quarto-debug.log")

# Enable debug mode
options(quarto.log.debug = TRUE)

# Log some information
quarto_log("Starting process")
quarto_log("R_LIBS:", Sys.getenv("R_LIBS"))
quarto_log(".libPaths():", paste0(.libPaths(), collapse = ":"))
} # }
```
