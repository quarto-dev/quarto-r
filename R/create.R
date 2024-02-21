#' Create a quarto project
#'
#' This function calls `quarto create project <type> <name>`. It will create a
#' new directory with the project name and add some skeletons files for the
#' project type chosen.
#'
#' # Quarto version required
#'
#' This function require Quarto 1.4 or higher. Use [`quarto_version()`]to check
#' the version of Quarto detected.
#'
#' @param type The type of project to create. As of 1.4, it can be one of
#'   `r paste0("\\code{", paste(quarto_project_type, collapse = "}, \\code{"),"}")`.
#' @param name The name of the project and the directory that will be created.
#' @param dir  The directory where to create the new Quarto project.
#'
#' @seealso Quarto documentation on [Quarto projects](https://quarto.org/docs/projects/quarto-projects.html)
#'
#' @inheritParams quarto_render
#' @inheritParams quarto_add_extension
#'
#' @export
quarto_create_project <- function(name, type = "default", dir = ".", no_prompt = FALSE, quiet = FALSE, quarto_args = NULL) {
  check_quarto_version("1.4", "quarto create project", "https://quarto.org/docs/projects/quarto-projects.html")

  if (rlang::is_missing(name)) {
    cli::cli_abort("You need to provide {.arg name} for the new project.")
  }

  if (rlang::is_interactive() && !no_prompt) {
    cli::cli_inform(c(
      "This will create a new Quarto {.emph {type}} project as a folder named {.strong {name}} in {.path {xfun::normalize_path(dir)}}."
    ))
    prompt_value <- tolower(readline(sprintf("Do you want to proceed (Y/n)? ")))
    if (!prompt_value %in% "y") {
      cli::cli_abort("Operation aborted.")
    }
  }

  quarto_bin <- find_quarto()

  args <- c("project", type, name, "--no-prompt", "--no-open", if (quiet) cli_arg_quiet(), quarto_args = NULL)

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
