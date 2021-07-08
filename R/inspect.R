#' Inspect Quarto Input File or Project
#'
#' Inspect a Quarto project or input path. Inspecting a project returns its
#' config and engines. Inspecting an input path return its formats, engine,
#' and dependent resources.
#'
#' @param input The input file or project directory to inspect.
#'
#' @return Named list. For input files, the list has members engine, format,
#'  and resources. For projects the list has members engines and config
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
#' }
#'
#' @export
quarto_inspect <- function(input = ".") {

  quarto_bin <- find_quarto()

  output <- system2(quarto_bin, stdout = TRUE, c(
    "inspect",
    path.expand(input)
  ))

  fromJSON(output)
}

