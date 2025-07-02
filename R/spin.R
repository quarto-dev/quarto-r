#' Add spin preamble to R script
#'
#' Adds a minimal spin preamble to an R script file if one doesn't already exist.
#' The preamble includes a title derived from the filename and is formatted as
#' a YAML block suitable preprended with `#'` for [knitr::spin()].
#'
#' This is useful to prepare R scripts for use with
#' Quarto Script rendering support.
#' See <https://quarto.org/docs/computations/render-scripts.html#knitr>
#'
#' @section Preamble format:
#' For a script named `analysis.R`, the function adds this preamble:
#' ```
#' #' ---
#' #' title: analysis
#' #' ---
#' #'
#'
#' # Original script content starts here
#' ```
#'
#' This is the minimal preamble required for Quarto Script rendering, so that
#' [Engine Bindings](https://quarto.org/docs/computations/execution-options.html#engine-binding) works.
#'
#' @param script Path to the R script file
#' @return Invisibly returns the script path if modified, otherwise invisible NULL
#' @export
add_spin_preamble <- function(script) {
  if (!fs::file_exists(script)) {
    cli::cli_abort(c(
      "File {.file {script}} does not exist.",
      "Please provide a valid file path."
    ))
  }
  content <- xfun::read_utf8(script)

  # if files starts with a spin preamble, do nothing
  if (grepl("^\\s*#'", content[1])) {
    cli::cli_inform(c(
      "File {.file {script}} already has a spin preamble.",
      "No changes made. Edit manually if needed."
    ))
    return(invisible())
  }
  # prepend the spin preamble
  filename <- fs::path_file(fs::path_ext_remove(script))
  preamble <- paste(
    "#'",
    xfun::split_lines(as_yaml_block(list(title = filename)))
  )
  new_content <- c(preamble, "", content) # Changed "\n" to ""
  xfun::write_utf8(new_content, con = script)

  cli::cli_inform("Added spin preamble to {.file {script}}")
  return(invisible(script))
}
