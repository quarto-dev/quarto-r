#' Read Quarto Metadata
#'
#' Read YAML metadata for an input file or project.
#'
#' @param input The input file or project directory to read metadata for.
#'
#' @return Named list with metadata. For input files, the named list
#'   is keyed by output format. For projects, all project level metadata
#'   defined in _quarto is contained in the list.
#'
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' \dontrun{
#' # Read metadata for file
#' quarto_metadata("notebook.Rmd")
#'
#' # Read metadata for project
#' quarto_metdata("myproject")
#' }
#'
#' @export
quarto_metadata <- function(input) {

  quarto_bin <- find_quarto()

  output <- system2(quarto_bin, stdout = TRUE, c(
    "metadata",
    input,
    "--json"
  ))

  fromJSON(output)
}
