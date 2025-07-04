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

  if (!file.exists(script)) {
    fs::file_create(script)
  }
  add_spin_preamble(script, preamble = fileInformation$metadata, quiet = TRUE)
}
