#' Check if a Quarto document uses parameters
#'
#' Determines whether a Quarto document uses parameters by examining the document
#' structure and metadata. This function works with both knitr and Jupyter engines,
#' using different detection methods for each:
#'
#' - **Knitr engine (.qmd files)**: Checks for a "params" field in the document's
#'   YAML metadata using `quarto_inspect()`
#' - **Jupyter engine (.ipynb files)**: Looks for code cells tagged with "parameters"
#'   following the papermill convention. For .ipynb files, the function parses the
#'   notebook JSON directly due to limitations in `quarto inspect`.
#'
#' @param input Path to the Quarto document (.qmd or .ipynb file) to inspect.
#'
#' @return Logical. `TRUE` if the document uses parameters, `FALSE` otherwise.
#'
#' @details
#' Parameters in Quarto enable creating dynamic, reusable documents. This function
#' helps identify parameterized documents programmatically, which is useful for:
#'
#' - Document processing workflows
#' - Automated report generation
#' - Parameter validation before rendering
#' - Project analysis and organization
#'
#' For more information about using parameters in Quarto, see
#' <https://quarto.org/docs/computations/parameters.html>
#'
#' @examples
#' \dontrun{
#' # Check if a document uses parameters
#' has_parameters("my-document.qmd")
#'
#' # Check a parameterized report
#' has_parameters("parameterized-report.qmd")
#'
#' # Check a Jupyter notebook
#' has_parameters("analysis.ipynb")
#'
#' # Use in a workflow
#' if (has_parameters("report.qmd")) {
#'   message("This document accepts parameters")
#' }
#' }
#'
#' @export
has_parameters <- function(input) {
  if (!file.exists(input)) {
    cli::cli_abort(
      c(
        "File {.file {input}} does not exist.",
        ">" = "Please provide a valid Quarto document."
      ),
      call = rlang::caller_env()
    )
  }

  # Check for Jupyter engine: look for cells with "parameters" tag
  # Note: quarto_inspect() has limitations with Jupyter notebooks and may not
  # detect code cells properly, so we fall back to direct JSON parsing for .ipynb files
  if (identical(fs::path_ext(input), "ipynb")) {
    return(has_parameters_jupyter_direct(input))
  }

  inspect <- quarto::quarto_inspect(input)

  if (identical(inspect$engines, "jupyter")) {
    return(
      "parameters" %in% inspect$fileInformation[[input]]$codeCells$metadata$tags
    )
  } else if (identical(inspect$engines, "knitr")) {
    return(
      "params" %in% names(inspect$fileInformation[[input]]$metadata)
    )
  } else {
    return(FALSE)
  }
}

# Helper function to directly parse Jupyter notebook JSON for parameters
# This is needed because quarto_inspect() has limitations with detecting
# code cells in Jupyter notebooks
has_parameters_jupyter_direct <- function(notebook_path) {
  tryCatch(
    {
      # Read and parse the notebook JSON with simplifyDataFrame = FALSE
      # to preserve the original structure
      notebook_json <- jsonlite::fromJSON(
        notebook_path,
        simplifyDataFrame = FALSE
      )

      # Check if there are cells
      if (length(notebook_json$cells) == 0) {
        return(FALSE)
      }
      # Look through cells for parameters tag
      any(sapply(notebook_json$cells, function(cell) {
        "parameters" %in% cell$metadata$tags
      }))
    },
    error = function(e) {
      # If JSON parsing fails, return FALSE
      return(FALSE)
    }
  )
}
