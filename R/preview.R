#' Quarto Preview
#'
#' Render and preview a Quarto document. Automatically re-renders the document
#' when the source file changes. Automatically reloads the browser when
#' document resources (e.g. CSS) change.
#'
#' Pass `render = FALSE` to prevent re-rendering when the source file
#' changes (note that even when this option is provided the document will be
#' rendered once before previewing).
#'
#' @inheritParams quarto_serve
#'
#' @param file Quarto document to preview.
#' @param render Automatically re-render the document when it changes.
#'
#' @examples
#' \dontrun{
#' # Preview a document
#' quarto_preview("document.qmd")
#'
#' # Stop any running preview
#' quarto_preview_stop()
#' }
#'
#' @export
quarto_preview <- function(file,
                           render = TRUE,
                           port = "auto",
                           host = "127.0.0.1",
                           browse = TRUE) {

  run_serve_daemon("preview", file, NULL, c(), render, port, host, browse)
}

#' @rdname quarto_preview
#' @export
quarto_preview_stop <- function() {
  stop_serve_daemon("preview")
}


