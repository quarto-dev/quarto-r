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
#'    - `DESCRIPTION` file with `Package:` field (R package or Project)
#'    - `.Rproj` files with `Version:` field (RStudio projects)
#'
#' Last fallback is the current working directory if no project root can be determined.
#' A warning is issued to alert users that behavior may differ between interactive use and Quarto rendering,
#' as in this case the computed path may be wrong.
#'
#' @section Use in Quarto document cells:
#'
#' This function is particularly useful in Quarto document cells where you want to
#' use a path relative to the project root dynamically during rendering.
#'
#' ````markdown
#' ```{r}`r ''`
#'  # Get a csv path from data directory in the Quarto project root
#'  data <- project_path("data", "my_data.csv")
#' ```
#' ````
#'
#' @param ... Character vectors of path components to be joined
#' @param root Project root directory. If `NULL` (default), automatic detection
#'   is used following the hierarchy described above
#' @return A character vector of the normalized file path relative to the project root.
#'
#' @examples
#' \dontrun{
#' # Create a dummy Quarto project structure for example
#' tmpdir <- tempfile("quarto_project")
#' dir.create(tmpdir)
#' quarto::quarto_create_project(
#'   'test project', type = 'blog',
#'   dir = tmpdir, no_prompt = TRUE, quiet = TRUE
#' )
#' project_dir <- file.path(tmpdir, "test project")
#'
#' # Simulate working within a blog post
#' xfun::in_dir(
#'   dir = file.path(project_dir, "posts", "welcome"), {
#'
#'   # Reference a data file from project root
#'   # ../../data/my_data.csv
#'   quarto::project_path("data", "my_data.csv")
#'
#'   # Reference a script from project root
#'   # ../../R/analysis.R
#'   quarto::project_path("R", "analysis.R")
#'
#'   # Explicitly specify root (overrides automatic detection)
#'   # ../../data/file.csv
#'   quarto::project_path("data", "file.csv", root = "../..")
#'
#'   # Alternative approach using here::i_am() (potentially more robust)
#'   # This approach requires you to declare where you are in the project:
#'   if (requireNamespace("here", quietly = TRUE)) {
#'     # Declare that this document is in the project root or subdirectory
#'     here::i_am("posts/welcome/index.qmd")
#'
#'     # Now here::here() will work reliably from the project root
#'     here::here("data", "my_data.csv")
#'     here::here("R", "analysis.R")
#'   }
#' })
#'
#' }
#'
#' @seealso
#' * [here::here()] and [here::i_am()] for a similar function that works with R projects
#' * [find_project_root()] to search for Quarto Project configuration in parents directories
#' * [get_running_project_root()] for detecting the project root in Quarto commands
#' * [xfun::from_root()] for the underlying path construction
#' * [xfun::proj_root()] for project root detection logic
#'
#' @export
project_path <- function(..., root = NULL) {
  if (is.null(root)) {
    # Try Quarto project environment variables first
    quarto_root <- get_running_project_root()

    root <- if (!is.null(quarto_root) && nzchar(quarto_root)) {
      quarto_root
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
            xfun::root_rules # Default rules (DESCRIPTION, .Rproj)
          )

          proj_root <- xfun::proj_root(rules = extended_rules)
          if (!is.null(proj_root)) {
            proj_root
          } else {
            cli::cli_warn(c(
              "Failed to determine project root using {.fun xfun::proj_root}. Using current working directory.",
              ">" = "This may lead to different behavior interactively vs running Quarto commands."
            ))
            getwd()
          }
        },
        error = function(e) {
          # Fall back to working directory if proj_root() fails
          cli::cli_warn(c(
            "Failed to determine project root: {e$message}. Using current working directory as a fallback.",
            ">" = "This may lead to different behavior interactively vs running Quarto commands."
          ))
          getwd() # Return the working directory
        }
      )
    }
  }

  # Normalize the root path
  root <- xfun::normalize_path(root)
  # Use xfun::from_root for better path handling
  path <- rlang::try_fetch(
    xfun::from_root(..., root = root, error = TRUE),
    error = function(e) {
      rlang::abort(
        c(
          "Failed to construct project path",
          ">" = "Ensure you are using valid path components."
        ),
        parent = e,
        call = rlang::caller_env()
      )
    }
  )
  path
}

#' Get the root of the currently running Quarto project
#'
#' @description
#' This function is to be used inside cells and will return the project root
#' when doing [quarto_render()] by detecting Quarto project environment variables.
#'
#' @details
#' Quarto sets `QUARTO_PROJECT_ROOT` and `QUARTO_PROJECT_DIR` environment
#' variables when executing commands within a Quarto project context (e.g.,
#' `quarto render`, `quarto preview`). This function detects their presence.
#'
#' Note that this function will return `NULL` when running code interactively
#' in an IDE (even within a Quarto project directory), as these specific
#' environment variables are only set during Quarto command execution.
#'
#' @section Use in Quarto document cells:
#'
#' This function is particularly useful in Quarto document cells where you want to
#' get the project root path dynamically during rendering. Cell example:
#'
#' ````markdown
#' ```{r}`r ''`
#'  # Get the project root path
#'  project_root <- get_running_project_root()
#' ```
#' ````
#'
#' @return Character Quarto project root path from set environment variables.
#'
#' @seealso
#'  * [find_project_root()] for finding the Quarto project root directory
#'  * [project_path()] for constructing paths relative to the project root
#' @examples
#' \dontrun{
#' get_running_project_root()
#' }
#' @export
get_running_project_root <- function() {
  root <- Sys.getenv("QUARTO_PROJECT_ROOT", Sys.getenv("QUARTO_PROJECT_DIR"))
  if (!nzchar(root)) {
    return()
  }
  root
}

#' Find the root of a Quarto project
#'
#' @description
#' This function checks if the current working directory is within a Quarto
#' project by looking for Quarto project files (`_quarto.yml` or `_quarto.yaml`).
#' Unlike [get_running_project_root()], this works both during rendering and
#' interactive sessions.
#'
#' @param path Character. Path to check for Quarto project files. Defaults to
#'   current working directory.
#'
#' @return Character Path of the project root directory if found, or `NULL`
#'
#' @examplesIf quarto_available()
#' tmpdir <- tempfile()
#' dir.create(tmpdir)
#' find_project_root(tmpdir)
#' quarto_create_project("test-proj", type = "blog", dir = tmpdir, no_prompt = TRUE, quiet = TRUE)
#' blog_post_dir <- file.path(tmpdir, "test-proj", "posts", "welcome")
#' find_project_root(blog_post_dir)
#'
#' xfun::in_dir(blog_post_dir, {
#'   # Check if current directory is a Quarto project or in one
#'   !is.null(find_project_root())
#' })
#'
#' # clean up
#' unlink(tmpdir, recursive = TRUE)
#'
#'
#' @seealso [get_running_project_root()] for detecting active Quarto rendering
#' @export
find_project_root <- function(path = ".") {
  quarto_rules <- rbind(
    c("_quarto.yml", ""),
    c("_quarto.yaml", "")
  )
  xfun::proj_root(path = path, rules = quarto_rules)
}
