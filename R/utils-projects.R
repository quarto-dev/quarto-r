#' Get path relative to project root (Quarto-aware)
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function constructs file paths relative to the project root when
#' running in a Quarto context (using `QUARTO_PROJECT_ROOT` or `QUARTO_PROJECT_DIR`
#' environment variables), or falls back to intelligent project root detection
#' when not in a Quarto context.
#'
#' It is experimental and subject to change in future releases. The automatic
#' project root detection may not work reliably in all contexts, especially when
#' projects have complex directory structures or when running in non-standard
#' environments. For a more explicit and potentially more robust approach,
#' consider using [here::i_am()] to declare your project structure,
#' followed by [here::here()] for path construction. See examples for comparison.
#'
#' @details
#' The function uses the following fallback hierarchy to determine the project root:
#'
#' - Quarto environment variables set during Quarto commands (e.g., `quarto render`):
#'   - `QUARTO_PROJECT_ROOT` environment variable (set by Quarto commands)
#'   - `QUARTO_PROJECT_DIR` environment variable (alternative Quarto variable)
#'
#' - Fallback to intelligent project root detection using [xfun::proj_root()] for interactive sessions:
#'    - `_quarto.yml` or `_quarto.yaml` (Quarto project files)
#'    - `.vscode` directory (VS Code/Positron workspace)
#'    - `DESCRIPTION` file with `Package:` field (R package or Project)
#'    - `.Rproj` files with `Version:` field (RStudio projects)
#'
#' Last fallback is the current working directory if no project root can be determined.
#' A warning is issued to alert users that behavior may differ between interactive use and Quarto rendering,
#' as in this case the computed path may be wrong.
#'
#' @param ... Character vectors of path components to be joined
#' @param root Project root directory. If `NULL` (default), automatic detection
#'   is used following the hierarchy described above
#' @return A character vector of the normalized file path relative to the project root
#'
#' @examples
#' \dontrun{
#' # Reference a data file from project root
#' data_path <- quarto::project_path("data", "my_data.csv")
#'
#' # Reference a script
#' script_path <- quarto::project_path("R", "analysis.R")
#'
#' # Reference nested directories
#' output_path <- quarto::project_path("outputs", "figures", "plot.png")
#'
#' # Explicitly specify root (overrides automatic detection)
#' custom_path <- quarto::project_path("data", "file.csv", root = "/path/to/project")
#'
#' # Alternative approach using here::i_am() (potentially more robust)
#' # This approach requires you to declare where you are in the project:
#' if (requireNamespace("here", quietly = TRUE)) {
#'   # Declare that this document is in the project root or subdirectory
#'   here::i_am("analysis.qmd")          # If in project root
#'   # here::i_am("reports/analysis.qmd") # If in subdirectory
#'
#'   # Now here::here() will work reliably from the project root
#'   data_path_alt <- here::here("data", "my_data.csv")
#'   script_path_alt <- here::here("R", "analysis.R")
#'   output_path_alt <- here::here("outputs", "figures", "plot.png")
#' }
#' }
#'
#' @seealso
#' * [here::here()] for a similar function that works with R projects
#' * [is_running_quarto_project()] to check if quarto is running with a project context
#' * [xfun::from_root()] for the underlying path construction
#' * [xfun::proj_root()] for project root detection logic
#'
#' @export
project_path <- function(..., root = NULL) {
  if (is.null(root)) {
    # Try Quarto project environment variables first
    quarto_root <- Sys.getenv(
      "QUARTO_PROJECT_ROOT",
      Sys.getenv("QUARTO_PROJECT_DIR")
    )

    if (nzchar(quarto_root)) {
      root <- quarto_root
    } else {
      # Try to find project root using xfun::proj_root() with extended rules
      tryCatch(
        {
          # Create extended rules that include Quarto and VS Code project files
          extended_rules <- rbind(
            # this should be the same as Quarto environment variables
            # which are only set when running Quarto commands
            c("_quarto.yml", ""), # Quarto project config
            c("_quarto.yaml", ""), # Alternative Quarto config
            # This is to provide some better fallback than just the working directory
            c(".vscode", ""), # VS Code/Positron workspace
            xfun::root_rules # Default rules (DESCRIPTION, .Rproj)
          )

          proj_root <- xfun::proj_root(rules = extended_rules)
          root <- if (!is.null(proj_root)) {
            proj_root
          } else {
            cli::cli_warn(
              "Failed to determine project root using {.fun xfun::proj_root}. Using current working directory.",
              ">" = "This may lead to different behavior interactively vs running Quarto commands."
            )
            getwd()
          }
        },
        error = function(e) {
          # Fall back to working directory if proj_root() fails
          cli::cli_warn(c(
            "Failed to determine project root: {e$message}. Using current working directory as a fallback.",
            ">" = "This may lead to different behavior interactively vs running Quarto commands."
          ))
          root <- getwd()
        }
      )
    }
  }

  # Use xfun::from_root for better path handling
  path <- tryCatch(
    xfun::from_root(..., root = root, error = FALSE),
    error = function(e) file.path(root, ...)
  )
  path
}

#' Check if running within a Quarto project context
#'
#' @description
#' This function checks if the current R session is running within a Quarto
#' project context by detecting Quarto project environment variables.
#'
#' @details
#' Quarto sets `QUARTO_PROJECT_ROOT` and `QUARTO_PROJECT_DIR` environment
#' variables when executing commands within a Quarto project context (e.g.,
#' `quarto render`, `quarto preview`). This function detects their presence.
#'
#' Note that this function will return `FALSE` when running code interactively
#' in an IDE (even within a Quarto project directory), as these specific
#' environment variables are only set during Quarto command execution.
#'
#' @return Logical indicating if Quarto project environment variables are set
#'
#' @seealso
#'  * [is_quarto_project()] for checking Quarto project structure
#'  * [project_path()] for constructing paths relative to the project root
#' @examples
#' \dontrun{
#' # This will be TRUE during `quarto render` in a project
#' is_running_quarto_project()
#'
#' # This will be FALSE when not running during `quarto_render` (e.g. interactively)
#' is_running_quarto_project()
#' }
#' @export
is_running_quarto_project <- function() {
  nzchar(Sys.getenv("QUARTO_PROJECT_ROOT")) ||
    nzchar(Sys.getenv("QUARTO_PROJECT_DIR"))
}

#' Check if working within a Quarto project structure
#'
#' @description
#' This function checks if the current working directory is within a Quarto
#' project by looking for Quarto project files (`_quarto.yml` or `_quarto.yaml`).
#' Unlike [is_running_quarto_project()], this works both during rendering and
#' interactive sessions.
#'
#' @param path Character. Path to check for Quarto project files. Defaults to
#'   current working directory.
#'
#' @return Logical indicating if a Quarto project structure is detected
#'
#' @examplesIf quarto_available()
#' dir <- tempfile()
#' dir.create(dir)
#' is_quarto_project(dir)
#' quarto_create_project(dir)
#' is_quarto_project(dir)
#'
#' xfun::in_dir(dir,
#'   # Check if current directory is in a Quarto project
#'   is_quarto_project()
#' )
#' # clean up
#' unlink(dir, recursive = TRUE)
#'
#'
#' @seealso [is_running_quarto_project()] for detecting active Quarto rendering
#' @export
is_quarto_project <- function(path = ".") {
  tryCatch(
    {
      quarto_rules <- rbind(
        c("_quarto.yml", ""),
        c("_quarto.yaml", "")
      )

      proj_root <- xfun::proj_root(path = path, rules = quarto_rules)
      !is.null(proj_root)
    },
    error = function(e) {
      FALSE
    }
  )
}
