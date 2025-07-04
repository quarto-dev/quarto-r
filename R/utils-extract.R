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

  if (!file.exists(script)) {
    fs::file_create(script)
  }
  add_spin_preamble(script, preamble = fileInformation$metadata)
}
