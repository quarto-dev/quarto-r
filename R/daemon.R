
run_serve_daemon <- function(command, target, wd, extra_args, render, port, host, browse) {

  # resolve target if provided
  if (!is.null(target)) {
    target <- path.expand(target)
  }

  # provide default for wd
  if (is.null(wd)) {
    wd <- getwd()
  }
  wd <- path.expand(wd)

  # calculate keys
  ps_key <- paste0(command, "_ps")
  port_key <- paste0(command, "_port")

  # manage existing server instances
  stop_serve_daemon(command)

  # if the last server had a port then re-use it for "auto"
  if (port == "auto") {
    if (!is.null(quarto[[port_key]])) {
      port <- quarto[[port_key]]
      quarto[[port_key]] <- NULL # don't re-use again unless we successfully bind
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

  # command and target
  args <- c(command)
  if (!is.null(target)) {
    args <- c(args, target)
  }

  # port and host
  args <- c(args, "--port", port)
  if (!identical(host, "127.0.0.1")) {
    args <- c(args, "--host", host)
  }

  # render
  if (!identical(render, "auto")) {
    if (is.logical(render)) {
      if (isFALSE(render)) {
        args <- c(args, "--no-render")
      }
    } else if (!identical(render, "none")) {
      args <- c(args, "--render", paste(render, collapse = ","))
    }
  }

  # no browse (we'll use browseURL)
  args <- c(args, "--no-browse")

  # add extra args
  args <- c(args, extra_args)

  # launch quarto serve
  quarto_bin <- find_quarto()
  quarto[[ps_key]] <- processx::process$new(
    quarto_bin,
    args,
    wd = wd,
    stdout = "|",
    stderr = "2>&1"
  )

  # wait for port to be bound to
  init <- ""
  while(!port_active(port)) {
    quarto[[ps_key]]$poll_io(50)
    cat(quarto[[ps_key]]$read_output())
    if (!quarto[[ps_key]]$is_alive()) {
      stop_serve_daemon(command)
      stop("Error starting quarto")
    }
  }
  quarto[[port_key]] <- port

  # monitor the process for abnormal exit
  poll_process <- function() {
    if (is.null(quarto[[ps_key]])) {
      return()
    }
    cat(quarto[[ps_key]]$read_output())
    if (!quarto[[ps_key]]$is_alive()) {
      status <- quarto[[ps_key]]$get_exit_status()
      quarto[[ps_key]] <- NULL
      if (status != 0) {
        stop("Error running quarto ", command)
      }
      return()
    }
    later::later(delay = 0.3, poll_process)
  }
  poll_process()


  # indicate server is running
  cat(paste0("Stop the preview with quarto_", command, "_stop()"))

  # run the preview browser
  if (!isFALSE(browse)) {
    if (!is.function(browse)) {
      browse <- ifelse(rstudioapi::isAvailable(),
                       rstudioapi::viewer,
                       utils::browseURL)
    }
    serve_url <- paste0("http://localhost:", port)
    browse(serve_url)
  }

  invisible()
}

stop_serve_daemon <- function(command) {
  ps_key <- paste0(command, "_ps")
  if (!is.null(quarto[[ps_key]])) {
    if (quarto[[ps_key]]$is_alive()) {
      ps <- quarto[[ps_key]]
      quarto[[ps_key]] <- NULL
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

