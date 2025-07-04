#' Extract R code from Quarto document
#'
#' Extracts R code cells from a Quarto document and writes them to an R script
#' file that can be rendered with the same options. The Markdown text is not
#' preserved, but R chunk options are kept as comment headers using Quarto's
#' `#|` syntax.
#'
#' @param qmd Character. Path to the input Quarto document (.qmd file).
#' @param script Character. Path to the output R script file. If `NULL`
#'   (default), the script file will have the same name as the input file
#'   but with `.R` extension.
#'
#' @details
#' This function processes a Quarto document by:
#' - Extracting only R code cells (markdown and cell in other languages are ignored)
#' - Preserving chunk options as `#|` comment headers
#' - Adding the document's YAML metadata as a spin-style header
#' - Creating an R script that can be rendered with the same options
#'
#' ## File handling:
#' - If the output R script already exists, the function will abort with an error
#' - Non-R code cells (e.g., Python, Julia, Observable JS) are ignored
#' - If no R code cells are found, the function does nothing and returns `NULL`
#'
#' ## Compatibility:
#' The resulting R script is compatible with Quarto's script rendering via
#' `knitr::spin()` and can be rendered directly with `quarto render script.R`.
#' See <https://quarto.org/docs/computations/render-scripts.html#knitr> for
#' more details on rendering R scripts with Quarto.
#'
#' The resulting R script uses Quarto's executable cell format with `#|`
#' comments to preserve chunk options like `echo`, `eval`, `output`, etc.
#'
#' @return Invisibly returns the path to the created R script file, or
#'   `NULL` if no R code cells were found.
#'
#' @examples
#' \dontrun{
#' # Extract R code from a Quarto document
#' extract_r_code("my-document.qmd")
#' # Creates "my-document.R"
#'
#' # Specify custom output file
#' extract_r_code("my-document.qmd", script = "extracted-code.R")
#' }
#'
#' @export
extract_r_code <- function(qmd, script = NULL) {
  if (!file.exists(qmd)) {
    cli::cli_abort(
      c(
        "File {.file {qmd}} does not exist.",
        ">" = "Please provide a valid Quarto document."
      ),
      call = rlang::caller_env()
    )
  }

  if (is.null(script)) {
    script <- fs::path_ext_set(qmd, "R")
  }

  if (file.exists(script)) {
    cli::cli_abort(
      c(
        "File {.file {script}} already exists.",
        ">" = "Please provide a new file name or remove the existing file."
      )
    )
  }

  inspect <- quarto::quarto_inspect(qmd)
  fileInformation <- inspect$fileInformation[[1]]

  codeCells <- fileInformation$codeCells
  if (length(codeCells) == 0) {
    cli::cli_inform(
      c(
        "No code cells found in {.file {qmd}}.",
        ">" = "This function only extracts R code cells."
      )
    )
    return(invisible(NULL))
  }
  if (all(codeCells$language != "r")) {
    cli::cli_inform(
      c(
        "No R code cells found in {.file {qmd}}, only: {.emph {paste(unique(codeCells$language))}}.",
        ">" = "This function only extracts R code cells."
      ),
      call = rlang::caller_env()
    )
    return(invisible(NULL))
  }

  if (any(codeCells$language != "r")) {
    cli::cli_inform(
      c(
        "Extracting only R code cells from {.file {qmd}}.",
        ">" = "Other languages will be ignored (found {.emph {paste(setdiff(unique(codeCells$language), 'r'))}})."
      ),
      call = rlang::caller_env()
    )
  }

  r_codeCells <- codeCells[codeCells$language == "r", ]

  content <- character(nrow(r_codeCells))
  for (i in seq_len(nrow(r_codeCells))) {
    row <- r_codeCells[i, ]
    metadata_list <- as.list(row$metadata)
    metadata_clean <- metadata_list[!is.na(metadata_list)]
    content[i] <- paste(
      c(create_code_preamble(metadata_clean), row$source),
      collapse = "\n"
    )
  }

  xfun::write_utf8(content, script)
  add_spin_preamble(script, preamble = fileInformation$metadata, quiet = TRUE)
}
