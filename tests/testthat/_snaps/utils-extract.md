# extract_r_code() errors on wrong qmd

    Code
      extract_r_code("nonexistent.qmd")
    Condition
      Error:
      ! File 'nonexistent.qmd' does not exist.
      > Please provide a valid Quarto document.

# extract_r_code() ignore other language code

    Code
      extract_r_code(resources_path("purl-r-ojs.qmd"), r_script)
    Message
      Extracting only R code cells from 'resources/purl-r-ojs.qmd'.
      > Other languages will be ignored (found ojs).

