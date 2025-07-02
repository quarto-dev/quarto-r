# Installing an extension in non empty dir errors

    Code
      quarto_use_template("quarto-journals/jss", no_prompt = TRUE, quiet = TRUE)
    Condition
      Error in `quarto_use_template()`:
      ! `dir` must be an empty directory.
      x The directory '.' is not empty.
        Please provide an empty directory or use `quarto use template quarto-journals/jss ` interactively in terminal.

