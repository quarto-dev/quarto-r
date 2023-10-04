#' Inspect Quarto Input File or Project
#'
#' Inspect a Quarto project or input path. Inspecting a project returns its
#' config and engines. Inspecting an input path return its formats, engine,
#' and dependent resources.
#'
#' @param input The input file or project directory to inspect.
#' @param profile [Quarto project
#'   profile](https://quarto.org/docs/projects/profiles.html) to use. If
#'   `NULL`, the default profile is used.
#'
#' @return Named list. For input files, the list contains the elements
#'   `quarto`, `engines`, `formats`, `resources`, plus `project` if the file is
#'   part of a Quarto project. For projects, the list contains the elements
#'   `quarto`, `dir`, `engines`, `config` and `files`.
#'
#' @importFrom jsonlite fromJSON
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
#' )}
#' @export
quarto_inspect <- function(input = ".",
                           profile = NULL) {

  quarto_bin <- find_quarto()

  output <- system2(
    command = quarto_bin,
    args = c(
      "inspect",
      if (!is.null(profile)) c("--profile", profile),
      path.expand(input)
    ),
    stdout = TRUE
  )

  fromJSON(output)
}
