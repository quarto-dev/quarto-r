#' @importFrom rmarkdown relative_to
relative_to_wd <- function(path) {
  rmarkdown::relative_to(getwd(), path)
}

#' Add quoted attribute to strings for YAML output
#'
#' This function allows users to explicitly mark strings that should be quoted
#' in YAML output, giving full control over quoting behavior.
#'
#' This is particularly useful for special values that might be misinterpreted
#' as \pkg{yaml} uses YAML 1.1 and Quarto expects YAML 1.2.
#'
#' The `quoted` attribute is a convention used by [yaml::as.yaml()]
#'
#' @param x A character vector or single string
#' @return The input with quoted attributes applied
#' @examples
#' yaml::as.yaml(list(id = yaml_quote_string("1.0")))
#' yaml::as.yaml(list(id = "1.0"))
#'
#' @export
yaml_quote_string <- function(x) {
  if (!is.character(x)) {
    cli::cli_abort("yaml_quote_string() only works with character vectors")
  }

  result <- vector("list", length(x))
  for (i in seq_along(x)) {
    val <- x[i]
    attr(val, "quoted") <- TRUE
    result[[i]] <- val
  }

  if (length(result) == 1) {
    return(result[[1]])
  }

  result
}

is_valid_yaml11_octal <- function(val) {
  # Check if the value is a valid YAML 1.1 octal number
  # Valid octals are 0o[0-7]+, but we only quote those with leading zeros
  # that contain digits 8 or 9, which are invalid in octal, as they
  # would not be quoted already by the R yaml package.
  # YAML 1.1 spec for int: https://yaml.org/type/int.html
  invalid <- !is.na(val) &&
    val != "" &&
    val != "0" &&
    grepl("^0[0-9]+$", val) &&
    grepl("[89]", val)
  !invalid
}

#' YAML character handler for YAML 1.1 to 1.2 compatibility
#'
#' This handler bridges the gap between R's yaml package (YAML 1.1) and
#' js-yaml (YAML 1.2) by quoting strings with leading zeros that would be
#' misinterpreted as octal numbers.
#'
#' According to YAML 1.1 spec, octal integers are `0o[0-7]+`. The R yaml
#' package only quotes valid octals (containing only digits 0-7), but js-yaml
#' attempts to parse ANY leading zero string as octal, causing data corruption
#' for invalid octals like "029" → 29.
#'
#' @seealso [YAML 1.1 int spec](https://yaml.org/type/int.html)
#'
#' @param x A character vector
#' @return The input with quoted attributes applied where needed
#' @keywords internal
yaml_character_handler <- function(x) {
  apply_quote <- function(x) {
    # Skip if already has quoted attribute (user control via yaml_quote_string())
    if (!is.null(attr(x, "quoted")) && attr(x, "quoted")) {
      return(x)
    }
    # Quote leading zero strings that are NOT valid octals (YAML 1.1 vs 1.2 gap)
    # Valid octals contain only digits 0-7, invalid ones contain 8 or 9
    if (!(is_valid_yaml11_octal(x))) {
      attr(x, "quoted") <- TRUE
    }
    return(x)
  }
  # For single elements, process directly
  if (length(x) == 1) {
    return(apply_quote(x))
  } else {
    # For vectors, process each element and return as list to preserve attributes
    result <- vector("list", length(x))
    for (i in seq_along(x)) {
      result[[i]] <- apply_quote(x[i])
    }
    return(result)
  }
}

# Specific YAML handlers
# as quarto expects YAML 1.2 and yaml R package supports 1.1
yaml_handlers <- list(
  logical = yaml::verbatim_logical,
  character = yaml_character_handler
)

#' @importFrom yaml as.yaml
as_yaml <- function(x) {
  check_params_for_na(x)
  yaml::as.yaml(x, handlers = yaml_handlers)
}

#' @importFrom yaml write_yaml
write_yaml <- function(x, file) {
  check_params_for_na(x)
  yaml::write_yaml(x, file, handlers = yaml_handlers)
}

as_yaml_block <- function(x) {
  # Convert to YAML and wrap in a block
  yaml_content <- as_yaml(x)
  paste0("---\n", yaml_content, "---\n")
}

check_params_for_na <- function(x) {
  # Recursively check for NA values
  check_na_recursive <- function(data, path = "") {
    if (is.list(data)) {
      for (i in seq_along(data)) {
        name <- names(data)[i] %||% as.character(i)
        new_path <- if (path == "") name else paste0(path, "$", name)
        check_na_recursive(data[[i]], new_path)
      }
    } else if (any(is.na(data) & !is.nan(data))) {
      # Found NA values (excluding NaN which is mathematically valid)
      na_positions <- which(is.na(data) & !is.nan(data))
      n_na <- length(na_positions)
      warn_or_error(c(
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

  check_na_recursive(x)
}


warn_or_error <- function(message, ..., .envir = parent.frame()) {
  if (is_cran_check()) {
    msg <- c(
      message,
      "!" = "This warning will become an error in future versions of Quarto R package."
    )
    cli::cli_warn(message = msg, ..., .envir = .envir)
  } else {
    cli::cli_abort(message = message, ..., .envir = .envir)
  }
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
    rlang::warn(
      "Directory {.path {dir}} does not exist. Assuming it is empty."
    )
    return(TRUE)
  }
  files <- list.files(dir, all.files = TRUE, no.. = TRUE)
  length(files) == 0
}
