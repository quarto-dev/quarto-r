#' Run Interactive Document
#'
#' Run a Shiny interactive document. By default, the document will
#' be rendered first and then run. If you have previously rendered
#' the document, pass `render - FALSE` to skip rendering.
#'
#' @param input The input file to run Should be a file with
#'   a `server: shiny` entry in its YAML front-matter.
#' @param render Render the document before running it.
#'
#' @inheritParams quarto_preview
#'
#' @export
quarto_run <- function(input,
                       render = TRUE,
                       port = getOption("shiny.port"),
                       host = getOption("shiny.host", "127.0.0.1"),
                       browse = TRUE) {

  # render if requested
  if (render) {
    quarto_render(input)
  }

  # build shiny args
  shiny_args <- list(
    port = port,
    host = host,
    launch.browser = browse
  )

  # we already ran quarto_render before the call to run
  # so disable rendering
  restore <- Sys.getenv("RMARKDOWN_RUN_PRERENDER", unset = NA)
  Sys.setenv(RMARKDOWN_RUN_PRERENDER = "0")
  if (!is.na(restore)) {
    on.exit(Sys.setenv(RMARKDOWN_RUN_PRERENDER = restore), add = TRUE)
  }

  # run the doc
  rmarkdown::run(input, shiny_args = shiny_args)
}


