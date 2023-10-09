

relative_to_wd <- function(path) {
  relative_to(getwd(), path)
}

#' @importFrom yaml write_yaml
write_yaml <- function(x, file) {
  handlers <- list(
    # Handle yes/no from 1.1 to 1.2
    # https://github.com/vubiostat/r-yaml/issues/131
    logical = function(x) {
    value <- ifelse(x, "true", "false")
    structure(value, class = "verbatim")
  })
  yaml::write_yaml(x, file, handlers = handlers)
}
