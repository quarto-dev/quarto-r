#' Quarto Development Server
#'
#' Run a local web server for a Quarto project.
#'
#' @param dir The project directory to serve (defaults to current working
#'   directory)
#' @param port Port to listen on (defaults to 4848)
#' @param render Render the site before serving it.
#' @param browse Open a browser to preview the site. Defaults to using the
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
                         port = "auto",
                         render = TRUE,
                         browse = TRUE,
                         watch = TRUE,
                         navigate = TRUE) {

  # provide default for dir
  if (is.null(dir)) {
    dir <- getwd()
  }

  # manage existing server instances
  quarto_serve_stop()

  # if the last server had a port then re-use it for "auto"
  if (port == "auto") {
    if (!is.null(quarto$port)) {
      port <- quarto$port
      quarto$port <- NULL # don't re-use again unless we successfully bind
    } else {
      port <- find_port()
      if (is.null(port)) {
        stop("Unable to find port to start server on")
      }
    }
  }

  # check for port availability
  if (port_active(port)) {
    stop("Server port ", port, " already in use.")
  }

  # render if requested
  if (!isFALSE(render)) {
    quarto_render(dir)
  }

  # build args
  args <- c("serve", "--port", port, "--quiet", "--no-browse", "--no-render")
  if (isFALSE(watch)) {
    args <- c(args, "--no-watch")
  }
  if (isFALSE(navigate)) {
    args <- c("--no-navigate")
  }

  # setup files to handle output streams
  quarto$stdout <- tempfile()
  quarto$stderr <- tempfile()

  # launch quarto serve
  quarto_bin <- find_quarto()
  quarto$ps <- processx::process$new(
    quarto_bin,
    args,
    wd = dir,
    stdout = quarto$stdout,
    stderr = quarto$stderr
  )

  # wait for port to be bound to
  while(!port_active(port)) {
    if (!quarto$ps$is_alive()) {
      quarto_serve_stop()
      stop("Error starting quarto: ", readLines(quarto$stderr))
    }
    Sys.sleep(0.2)
  }
  quarto$port <- port

  # monitor the process for abnormal exit
  poll_process <- function() {
    if (is.null(quarto$ps)) {
      return()
    }
    if (!quarto$ps$is_alive()) {
      status <- quarto$ps$get_exit_status()
      quarto$ps <- NULL
      if (status != 0) {
        stop("Error running quarto server: ", readLines(quarto$stderr))
      }
      return()
    }
    later::later(delay = 1, poll_process)
  }
  poll_process()


  # indicate server is running
  serve_url <- paste0("http://localhost:", port)
  message("Serving site from ", dir)
  if (watch) {
    message("  Watching project for reload on changes")
  }
  message("  Browse the site at ", serve_url)
  message("  Stop the server with quarto_serve_stop()")

  # run the preview browser
  if (!isFALSE(browse)) {
    if (!is.function(browse)) {
      browse <- ifelse(rstudioapi::isAvailable(),
                       rstudioapi::viewer,
                       utils::browseURL)
    }
    browse(serve_url)
  }

  invisible()
}

#' @rdname quarto_serve
#' @export
quarto_serve_stop <- function() {
  if (!is.null(quarto$ps)) {
    if (quarto$ps$is_alive()) {
      ps <- quarto$ps
      quarto$ps <- NULL
      ps$interrupt()
      ps$poll_io(500)
      ps$kill()
      ps$wait(3000)
    }
  }
  Sys.sleep(0.5)
  invisible()
}

find_port <- function(port) {
  for (i in 1:20) {
    # determine the port (exclude those considered unsafe by Chrome)
    while(TRUE) {
      port <- 3000 + sample(5000, 1)
      if (!port %in% c(3659, 4045, 6000, 6665:6669,6697))
        break
    }
    # see if it's active
    if (!port_active(port)) {
      return(port)
    }
  }
  NULL
}

port_active <- function(port) {
  tryCatch({
    suppressWarnings(con <- socketConnection("127.0.0.1", port, timeout = 1))
    close(con)
    TRUE
  }, error = function(e) FALSE)
}

