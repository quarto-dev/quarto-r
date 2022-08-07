#' Quarto Preview
#'
#' Render and preview a Quarto document or website project.
#'
#' Automatically reloads the browser when input files are re-rendered or
#' document resources (e.g. CSS) change.
#'
#' @param file The document or website project directory to preview (defaults to
#'  current working directory)
#' @param render For website preview, the most recent execution results of
#'   computational documents are used to render the site (this is to optimize
#'   startup time). If you want to perform a full render prior to serving pass
#'   "all" or a vector of specific formats to render. Pass "default" to render
#'   the default format for the site. For document preview, the document is
#'   rendered prior to preview (pass `FALSE` to override this).
#' @param port Port to listen on (defaults to 4848)
#' @param host Hostname to bind to (defaults to 127.0.0.1)
#' @param browse Open a browser to preview the content. Defaults to using the
#'   RStudio Viewer when running within RStudio.Pass a function (e.g.
#'   `utils::browseURL` to override this behavior).
#' @param watch Watch for changes and automatically reload browser.
#' @param navigate Automatically navigate the preview browser to the most
#'   recently rendered document.
#'
#' @importFrom processx process
#' @importFrom rstudioapi isAvailable
#' @importFrom rstudioapi viewer
#' @importFrom utils browseURL
#' @importFrom later later
#'
#' @examples
#' \dontrun{
#' # Preview the project in the current directory
#' quarto_preview()
#'
#' # Preview a document
#' quarto_preview("document.qmd")
#'
#' # Preview the project in "myproj" directory and use external browser
#' # (rather than RStudio Viewer)
#' quarto_preview("myproj", open = utils::browseURL)
#'
#' # Stop any running quarto preview
#' quarto_preview_stop()
#' }
#'
#' @export
quarto_preview <- function(file = NULL,
                           render = "auto",
                           port = "auto",
                           host = "127.0.0.1",
                           browse = TRUE,
                           watch = TRUE,
                           navigate = TRUE) {

  # default for file
  if (is.null(file)) {
    file = getwd()
  }

  # handle extra_args
  args <- c()
  if (isFALSE(watch)) {
    args <- c(args, "--no-watch")
  }
  if (isFALSE(navigate)) {
    args <- c("--no-navigate")
  }

  # serve
  run_serve_daemon("preview",
                   file,
                   NULL,
                   args,
                   render,
                   port,
                   host,
                   browse)
}

#' @rdname quarto_preview
#' @export
quarto_preview_stop <- function() {
  stop_serve_daemon("preview")
}

