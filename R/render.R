#' Render Markdown
#'
#' Render the input file to the specified output format using quarto. If the
#' input requires computations (e.g. for Rmd or Jupyter files) then those
#' computations are performed before rendering.
#'
#' @param input The input file or project directory to be rendered (defualts
#'   to rendering the project in the current working directory).
#' @param output_format Target output format (defaults to "html"). The option
#'   `"all"` will render all formats defined within the file or project.
#' @param output_file The name of the output file. If using `NULL` then the
#'   output filename will be based on filename for the input file.
#' @param execute Whether to execute embedded code chunks.
#' @param execute_params A list of named parameters that override custom params
#'   specified within the YAML front-matter.
#' @param execute_dir The working directory in which to execute embedded code
#'   chunks.
#' @param cache Cache execution output (uses knitr cache and jupyter-cache
#'   respectively for Rmd and Jupyter input files).
#' @param cache_refresh Force refresh of execution cache.
#' @param kernel_keepalive Keep Jupyter kernel alive (defaults to 300 seconds).
#'   Note this option is only applicable for rendering Jupyter notebooks or
#'   Jupyter markdown.
#' @param kernel_restart Restart keepalive Jupyter kernel before render.
#'   Note this option is only applicable for rendering Jupyter notebooks or
#'   Jupyter markdown.
#' @param debug Leave intermediate files in place after render.
#' @param quiet Suppress warning and other messages.
#' @param pandoc_args Additional command line options to pass to pandoc.
#'
#' @importFrom rmarkdown relative_to
#' @importFrom yaml write_yaml
#'
#' @examples
#' \dontrun{
#' # Render R Markdown
#' quarto_render("notebook.Rmd")
#' quarto_render("notebook.Rmd", output_format = "pdf")
#'
#' # Render Jupyter Notebook
#' quarto_render("notebook.ipynb")
#'
#' # Render Jupyter Markdown
#' quarto_render("notebook.md")
#' }
#' @export
quarto_render <- function(input = NULL,
                          output_format = NULL,
                          output_file = NULL,
                          execute = TRUE,
                          execute_params = NULL,
                          execute_dir = NULL,
                          cache = NULL,
                          cache_refresh = FALSE,
                          kernel_keepalive = NULL,
                          kernel_restart = FALSE,
                          debug = FALSE,
                          quiet = FALSE,
                          pandoc_args = NULL) {

  # provide default for input
  if (is.null(input)) {
    input <- getwd()
  }

  # get quarto binary
  quarto_bin <- find_quarto()

  # build args
  args <- c("render", input)
  if (!missing(output_format)) {
    args <- c(args, "--to", paste(output_format, collapse = ","))
  }
  if (!missing(output_file)) {
    args <- c(args, "--output", output_file)
  }
  if (!missing(execute)) {
    args <- c(args, ifelse(isTRUE(execute), "--execute", "--no-execute"))
  }
  if (!missing(execute_params)) {
    params_file <- tempfile(pattern = "quarto-params", fileext = ".yml")
    write_yaml(execute_params, params_file)
    args <- c(args, "--execute-params", params_file)
  }
  if (!missing(execute_dir)) {
    args <- c(args, "--execute-dir", execute_dir)
  }
  if (!missing(cache)) {
    args <- c(args, ifelse(isTRUE(cache), "--cache", "--no-cache"))
  }
  if (isTRUE(cache_refresh)) {
    args <- c(args, "--cache-refresh")
  }
  if (!missing(kernel_keepalive)) {
    args <- c(args, "--kernel-keepalive", as.character(kernel_keepalive))
  }
  if (isTRUE(kernel_restart)) {
    args <- c(args, "--kernel-restart")
  }
  if (isTRUE(debug)) {
    args <- c(args, "--debug")
  }
  if (isTRUE(quiet)) {
    args <- c(args, "--quiet")
  }

  # run quarto
  processx::run(quarto_bin, args, echo = TRUE)

  # no return value
  invisible(NULL)
}






