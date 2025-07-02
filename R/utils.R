#' @importFrom rmarkdown relative_to
relative_to_wd <- function(path) {
  rmarkdown::relative_to(getwd(), path)
}

# Specific YAML handlers
# as quarto expects YAML 1.2 and yaml R package supports 1.1
yaml_handlers <- list(
  # Handle yes/no from 1.1 to 1.2
  # https://github.com/vubiostat/r-yaml/issues/131
  logical = function(x) {
    value <- ifelse(x, "true", "false")
    structure(value, class = "verbatim")
  }
)

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
        "i" = "Quarto parameters cannot contain NA values",
        " " = "Consider these alternatives:",
        "*" = "Remove NA values from your data before passing to Quarto",
        "*" = "Use {.code NULL} instead of {.code NA} for missing optional parameters",
        "*" = "Handle missing values within your document code using conditional logic"
      ))
    }
  }

  check_na_recursive(params)
}

#' @importFrom yaml as.yaml
as_yaml <- function(x) {
  yaml::as.yaml(x, handlers = yaml_handlers)
}

#' @importFrom yaml write_yaml
write_yaml <- function(x, file) {
  yaml::write_yaml(x, file, handlers = yaml_handlers)
}

as_yaml_block <- function(x) {
  # Convert to YAML and wrap in a block
  yaml_content <- as_yaml(x)
  paste0("---\n", yaml_content, "---\n")
}


# inline knitr:::merge_list()
merge_list <- function(x, y) {
  x[names(y)] <- y
  x
}

`%||%` <- function(x, y) {
  if (rlang::is_null(x)) y else x
}

in_positron <- function() {
  identical(Sys.getenv("POSITRON"), "1")
}

in_rstudio <- function() {
  identical(Sys.getenv("RSTUDIO"), "1")
}


# for test

hide_path <- function(path) {
  function(x) {
    x <- gsub(path, "<project directory>", x, fixed = TRUE)
    gsub(fs::path_real(path), "<project directory>", x, fixed = TRUE)
  }
}

has_internet <- function(host = "https://www.google.com") {
  tryCatch(
    {
      headers <- curlGetHeaders(host)
      # If we get headers back, we have internet
      !is.null(headers) && length(headers) > 0
    },
    error = function(e) {
      FALSE
    }
  )
}

is_empty_dir <- function(dir) {
  if (!dir.exists(dir)) {
    return(FALSE)
  }
  files <- list.files(dir, all.files = TRUE, no.. = TRUE)
  length(files) == 0
}
