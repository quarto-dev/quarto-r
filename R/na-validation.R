check_params_for_na <- function(params) {
  # Recursively check for NA values
  check_na_recursive <- function(x, path = "") {
    if (is.list(x)) {
      for (i in seq_along(x)) {
        name <- names(x)[i] %||% as.character(i)
        new_path <- if (path == "") name else paste0(path, "$", name)
        check_na_recursive(x[[i]], new_path)
      }
    } else if (any(is.na(x) & !is.nan(x))) {
      # Found NA values (excluding NaN which is mathematically valid)
      na_positions <- which(is.na(x) & !is.nan(x))
      n_na <- length(na_positions)

      cli::cli_abort(c(
        "{.code NA} values detected in parameter {.field {path}}",
        "x" = "Found NA at position{if (n_na > 1) 's' else ''}: {.val {na_positions}}",
        "i" = "Quarto CLI uses YAML 1.2 spec which cannot process R's {.code NA} values",
        "i" = "R's {.code NA} gets converted to YAML strings (like {.code .na.real}) that Quarto doesn't recognize as missing values",
        " " = "Consider these alternatives:",
        "*" = "Remove NA values from your data before passing to Quarto",
        "*" = "Use {.code NULL} instead of {.code NA} for missing optional parameters",
        "*" = "Handle missing values within your document code using conditional logic"
      ))
    }
  }

  check_na_recursive(params)
}
