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
#' @param execute_daemon Keep Jupyter kernel alive (defaults to 300 seconds).
#'   Note this option is only applicable for rendering Jupyter notebooks or
#'   Jupyter markdown.
#' @param execute_daemon_restart Restart keepalive Jupyter kernel before render.
#'   Note this option is only applicable for rendering Jupyter notebooks or
#'   Jupyter markdown.
#' @param execute_debug Show debug output for Jupyter kernel.
#' @param cache Cache execution output (uses knitr cache and jupyter-cache
#'   respectively for Rmd and Jupyter input files).
#' @param cache_refresh Force refresh of execution cache.
#' @param debug Leave intermediate files in place after render.
#' @param quiet Suppress warning and other messages.
#' @param pandoc_args Additional command line options to pass to pandoc.
#' @param as_job Render as an RStudio background job. Default is "auto",
#'   which will render individual documents normally and projects as
#'   background jobs. Use the `quarto.render_as_job` R option to control
#'   the default globally.
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
                          execute_daemon = NULL,
                          execute_daemon_restart = FALSE,
                          execute_debug = FALSE,
                          cache = NULL,
                          cache_refresh = FALSE,
                          debug = FALSE,
                          quiet = FALSE,
                          pandoc_args = NULL,
                          as_job = getOption("quarto.render_as_job", "auto")) {

  # provide default for input
  if (is.null(input)) {
    input <- getwd()
  }
  input <- path.expand(input)

  # get quarto binary
  quarto_bin <- find_quarto()

  # see if we need to render as a job
  if (identical(as_job, "auto")) {
    as_job <- utils::file_test("-d", input)
  }

  # render as job if requested and running within rstudio
  if (as_job && rstudioapi::isAvailable()) {
    message("Rendering project as backround job (use as_job = FALSE to override)")
    script <- tempfile(fileext = ".R")
    writeLines(
      c("library(quarto)", deparse(sys.call())),
      script
    )
    rstudioapi::jobRunScript(
      script,
      name = "quarto render",
      workingDir = getwd(),
      importEnv = TRUE
    )
    return (invisible(NULL))
  }


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
  if (!missing(execute_daemon)) {
    args <- c(args, "--execute-daemon", as.character(execute_daemon))
  }
  if (isTRUE(execute_daemon_restart)) {
    args <- c(args, "--execute-daemon-restart")
  }
  if (isTRUE(execute_debug)) {
    args <- c(args, "--execute-debug")
  }
  if (!missing(cache)) {
    args <- c(args, ifelse(isTRUE(cache), "--cache", "--no-cache"))
  }
  if (isTRUE(cache_refresh)) {
    args <- c(args, "--cache-refresh")
  }
  if (isTRUE(debug)) {
    args <- c(args, "--debug")
  }
  if (isTRUE(quiet)) {
    args <- c(args, "--quiet")
  }
  if (!is.null(pandoc_args)) {
    args <- c(args, pandoc_args)
  }

  # run quarto
  processx::run(quarto_bin, args, echo = TRUE)

  # no return value
  invisible(NULL)
}






