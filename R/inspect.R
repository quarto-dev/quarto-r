#' Inspect Quarto Input File or Project
#'
#' Inspect a Quarto project or input path. Inspecting a project returns its
#' config and engines. Inspecting an input path return its formats, engine,
#' and dependent resources.
#'
#' @inheritParams quarto_render
#'
#' @param input The input file or project directory to inspect.
#'
#' @return Named list. For input files, the list contains the elements
#'   `quarto`, `engines`, `formats`, `resources`, `fileInformation` plus `project` if the file is
#'   part of a Quarto project. For projects, the list contains the elements
#'   `quarto`, `dir`, `engines`, `config` and `files`.
#'
#' @examples
#' \dontrun{
#' # Inspect input file file
#' quarto_inspect("notebook.Rmd")
#'
#' # Inspect project
#' quarto_inspect("myproject")
#'
#' # Inspect project's advanced profile
#' quarto_inspect(
#'   input = "myproject",
#'   profile = "advanced"
#' )
#' }
#' @importFrom jsonlite fromJSON
#' @export
quarto_inspect <- function(
  input = ".",
  profile = NULL,
  quiet = FALSE,
  quarto_args = NULL
) {
  quarto_bin <- find_quarto()

  args <- c("inspect", path.expand(input))

  if (!is.null(profile)) {
    args <- c(args, c("--profile", paste0(profile, collapse = ",")))
  }

  if (is_quiet(quiet)) {
    args <- cli_arg_quiet(args)
  }

  args <- c(args, quarto_args)

  res <- quarto_run(args, quarto_bin = quarto_bin)

  fromJSON(res$stdout)
}
