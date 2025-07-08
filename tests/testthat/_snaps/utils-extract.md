# qmd_to_r_script() errors on wrong qmd

    Code
      qmd_to_r_script("nonexistent.qmd")
    Condition
      Error:
      ! File 'nonexistent.qmd' does not exist.
      > Please provide a valid Quarto document.

# qmd_to_r_script() errors on existing script

    Code
      qmd_to_r_script(resources_path("purl-r.qmd"), script = r_script)
    Condition
      Error in `qmd_to_r_script()`:
      ! File <r script> already exists.
      > Please provide a new file name or remove the existing file.

# qmd_to_r_script() ignore other language code

    Code
      qmd_to_r_script(resources_path("purl-r-ojs.qmd"), r_script)
    Message
      Extracting only R code cells from 'resources/purl-r-ojs.qmd'.
      > Other languages will be ignored (found ojs).

