#' Quarto Development Server
#'
#' Run a local web server for a Quarto project.
#'
#' @param dir The project directory to serve (defaults to current working
#'   directory)
#' @param render By default, the most recent execution results of computational
#'  documents are used to render the site (this is to optimize start up time).
#'  If you want to perform a full render prior to serving pass "all" or a
#'  vector of specific formats to render. Pass "default" to render the default
#'  format for the site.
#' @param port Port to listen on (defaults to 4848)
#' @param host Hostname to bind to (defaults to 127.0.0.1)
#' @param browse Open a browser to preview the content. Defaults to using the
#'   RStudio Viewer when running within RStudio.Pass a function (e.g.
#'   `utils::browseURL` to override this behavior).
#' @param watch Watch for changes and automatically reload browser.
#' @param navigate Automatically navivate the preview browser to the most
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
#' # Run a local server for the project in the current directory
#' quarto_serve()
#'
#' # Run server for project in "myproj" directory and preview in external
#' # browser (rather than RStudio Viewer)
#' quarto_serve("myproj", open = utils::browseURL)
#'
#' # Stop any running quarto server
#' quarto_serve_stop()
#' }
#'
#' @export
quarto_serve <- function(dir = NULL,
                         render = "none",
                         port = "auto",
                         host = "127.0.0.1",
                         browse = TRUE,
                         watch = TRUE,
                         navigate = TRUE) {

  # handle extra_args
  args <- c()
  if (isFALSE(watch)) {
    args <- c(args, "--no-watch")
  }
  if (isFALSE(navigate)) {
    args <- c("--no-navigate")
  }

  # serve
  run_serve_daemon("serve", NULL, dir, args, render, port, host, browse)
}

#' @rdname quarto_serve
#' @export
quarto_serve_stop <- function() {
  stop_serve_daemon("serve")
}

