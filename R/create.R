#' Create a quarto project
#'
#' This function calls `quarto create project <type> <name>`. It creates a new
#' directory with the project name, inside the requested parent directory, and
#' adds some starter files that are appropriate to the project type.
#'
#' # Quarto version required
#'
#' This function requires Quarto 1.4 or higher. Use [quarto_version()] to see
#' your current Quarto version.
#'
#' @param type The type of project to create. As of Quarto 1.4, it can be one of
#'   `r paste0("\\code{", paste(quarto_project_type, collapse = "}, \\code{"),"}")`.
#' @param name The name of the project and the directory that will be created. Special case
#' is to use `name = "."` to create the project in the current directory. In that case provide `title`
#' to set the project title.
#' @param title The title of the project. By default, it will be the name of the project, same as directory name created.
#' or "My project" if `name = "."`. If you want to set a different title, provide it here.
#' @param dir The directory in which to create the new Quarto project, i.e. the
#'   parent directory.
#'
#' @seealso Quarto documentation on [Quarto projects](https://quarto.org/docs/projects/quarto-projects.html)
#'
#' @inheritParams quarto_render
#' @param no_prompt Do not prompt to approve the creation of the new project
#'   folder.
#'
#' @examples
#' \dontrun{
#' # Create a new project directory in another directory
#' quarto_create_project("my-first-quarto-project", dir = "~/tmp")
#'
#' # Create a new project directory in the current directory
#' quarto_create_project("my-first-quarto-project")
#'
#' # Create a new project with a different title
#' quarto_create_project("my-first-quarto-project", title = "My Quarto Project")
#'
#' # Create a new project inside the current directory directly
#' quarto_create_project(".", title = "My Quarto Project")
#' }
#'
#'
#' @export
quarto_create_project <- function(
  name,
  type = "default",
  dir = ".",
  title = name,
  no_prompt = FALSE,
  quiet = FALSE,
  quarto_args = NULL
) {
  check_quarto_version(
    "1.4",
    "quarto create project <type> <name>",
    "https://quarto.org/docs/projects/quarto-projects.html"
  )

  if (rlang::is_missing(name)) {
    cli::cli_abort("You need to provide {.arg name} for the new project.")
  }

  # If title is provided, check for Quarto version 1.5.15 or higher
  if (title != name) {
    check_quarto_version(
      "1.5.15",
      "quarto create project <type> <name> <title>",
      "https://quarto.org/docs/projects/quarto-projects.html"
    )
  }

  if (rlang::is_interactive() && !no_prompt) {
    folder_msg <- if (name != ".") {
      "as a folder named {.strong {name}}"
    }
    cli::cli_inform(c(
      paste(
        "This will create a new Quarto {.emph {type}} project",
        folder_msg,
        "in {.path {xfun::normalize_path(dir)}}."
      ),
      "Project title will be set to {.strong {title}}."
    ))
    prompt_value <- tolower(readline(sprintf("Do you want to proceed (Y/n)? ")))
    if (!prompt_value %in% c("", "y")) {
      cli::cli_abort("Operation aborted.")
    }
  }

  quarto_bin <- find_quarto()

  args <- c(
    "project",
    type,
    name,
    title,
    "--no-prompt",
    "--no-open",
    if (is_quiet(quiet)) cli_arg_quiet(),
    quarto_args = NULL
  )

  owd <- setwd(dir)
  on.exit(setwd(owd), add = TRUE, after = FALSE)
  quarto_create(args, quarto_bin = quarto_bin, echo = TRUE)
}

quarto_create <- function(args = character(), ...) {
  quarto_run_what("create", args = args, ...)
}


# This list is for 1.4
quarto_project_type <- c(
  "default",
  "website",
  "blog",
  "book",
  "manuscript",
  "confluence"
)
