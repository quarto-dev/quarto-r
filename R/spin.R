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
#' For a script named `analysis.R`, the function adds this preamble by default:
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
#' @param title Custom title for the preamble. If provided, overrides any title
#'   in the `preamble` list. If NULL, uses `preamble$title` or filename as fallback.
#' @param preamble Named list of YAML metadata to include in preamble.
#'   The `title` parameter takes precedence over `preamble$title` if both are provided.
#' @param quiet If `TRUE`, suppresses messages and warnings.
#' @return Invisibly returns the script path if modified, otherwise invisible NULL
#'
#' @examples
#' \dontrun{
#' # Basic usage with default title
#' add_spin_preamble("analysis.R")
#'
#' # Custom title
#' add_spin_preamble("analysis.R", title = "My Analysis")
#'
#' # Custom preamble with multiple fields
#' add_spin_preamble("analysis.R", preamble = list(
#'   title = "Advanced Analysis",
#'   author = "John Doe",
#'   date = Sys.Date(),
#'   format = "html"
#' ))
#'
#' # Title parameter overrides preamble title
#' add_spin_preamble("analysis.R",
#'   title = "Final Title",  # This takes precedence
#'   preamble = list(
#'     title = "Ignored Title",
#'     author = "John Doe"
#'   )
#' )
#' }
#' @export
add_spin_preamble <- function(
  script,
  title = NULL,
  preamble = NULL,
  quiet = FALSE
) {
  if (!fs::file_exists(script)) {
    cli::cli_abort(
      c(
        "File {.file {script}} does not exist.",
        "Please provide a valid file path."
      )
    )
  }

  content <- xfun::read_utf8(script)

  # if files starts with a spin preamble, do nothing
  if (grepl("^\\s*#'", content[1])) {
    if (isFALSE(quiet)) {
      cli::cli_inform(c(
        "File {.file {script}} already has a spin preamble.",
        "No changes made. Edit manually if needed."
      ))
    }
    return(invisible())
  }

  # Build preamble metadata
  metadata <- list()

  # Start with preamble list if provided
  if (!is.null(preamble)) {
    if (!is.list(preamble)) {
      cli::cli_abort("`preamble` must be a named list.")
    }
    metadata <- preamble
  }

  # Add or override title
  if (!is.null(title)) {
    metadata$title <- title
  } else if (is.null(metadata$title)) {
    # Use filename as default title if none provided
    metadata$title <- fs::path_file(fs::path_ext_remove(script))
  }

  preamble_text <- create_header_preamble(metadata)

  new_content <- c(preamble_text, "", content)
  xfun::write_utf8(new_content, con = script)

  if (isFALSE(quiet)) {
    cli::cli_inform(c(
      "Added spin preamble to {.file {script}}."
    ))
  }
  return(invisible(script))
}

create_header_preamble <- function(metadata) {
  if (length(metadata) == 0) {
    return("")
  }
  build_preamble("#'", as_yaml_block(metadata))
}

create_code_preamble <- function(metadata) {
  if (length(metadata) == 0) {
    return("")
  }
  # Remove trailing newline for this block as `as_yaml` adds one
  build_preamble("#|", sub("\n$", "", as_yaml(metadata)))
}

build_preamble <- function(prepend, content) {
  if (!nzchar(content)) {
    return("")
  }
  paste(
    prepend,
    xfun::split_lines(content)
  )
}
