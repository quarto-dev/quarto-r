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
