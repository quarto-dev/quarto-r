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

#' @importFrom yaml as.yaml
as_yaml <- function(x) {
  yaml::as.yaml(x, handlers = yaml_handlers)
}

#' @importFrom yaml write_yaml
write_yaml <- function(x, file) {
  yaml::write_yaml(x, file, handlers = yaml_handlers)
}


# inline knitr:::merge_list()
merge_list <- function(x, y) {
  x[names(y)] <- y
  x
}

`%||%` <- function(x, y) {
  if (is_null(x)) y else x
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
