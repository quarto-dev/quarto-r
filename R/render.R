#' Render Markdown
#'
#' Render the input file to the specified output format using quarto. If the
#' input requires computations (e.g. for Rmd or Jupyter files) then those
#' computations are performed before rendering.
#'
#' @param input The input file or project directory to be rendered (defaults
#'   to rendering the project in the current working directory).
#' @param output_format Target output format (defaults to `"html"`). The option
#'   `"all"` will render all formats defined within the file or project.
#' @param output_file The name of the output file. If using `NULL`, the output
#'   filename will be based on the filename for the input file. `output_file` is
#'   mapped to the `--output` option flag of the `quarto` CLI. It is expected to
#'   be a filename only, not a path, relative or absolute.
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
#' @param use_freezer Force use of frozen computations for an incremental
#'  file render.
#' @param cache Cache execution output (uses knitr cache and jupyter-cache
#'  respectively for Rmd and Jupyter input files).
#' @param cache_refresh Force refresh of execution cache.
#' @param metadata An optional named list used to override YAML
#'   metadata. It will be passed as a YAML file to `--metadata-file` CLI flag.
#'   This will be merged over `metadata-file` options if both are
#'   specified.
#' @param metadata_file A yaml file passed to `--metadata-file` CLI flags to
#'   override metadata. This will be merged with `metadata` if both are
#'   specified, with low precedence on `metadata` options.
#' @param debug Leave intermediate files in place after render.
#' @param quiet Suppress warning and other messages, from R and also Quarto CLI
#'   (i.e `--quiet` is passed as command line).
#'
#'   `quarto.quiet` \R option or `R_QUARTO_QUIET` environment variable can be used to globally override a function call
#'   (This can be useful to debug tool that calls `quarto_*` functions directly).
#'
#'   On Github Actions, it will always be `quiet = FALSE`.
#' @param profile [Quarto project
#'   profile(s)](https://quarto.org/docs/projects/profiles.html) to use. Either
#'   a character vector of profile names or `NULL` to use the default profile.
#' @param quarto_args Character vector of other `quarto` CLI arguments to append
#'   to the Quarto command executed by this function. This is mainly intended for
#'   advanced usage and useful for CLI arguments which are not yet mirrored in a
#'   dedicated parameter of this \R function. See `quarto render --help` for options.
#' @param pandoc_args Additional command line arguments to pass on to Pandoc.
#' @param as_job Render as an RStudio background job. Default is `"auto"`,
#'   which will render individual documents normally and projects as
#'   background jobs. Use the `quarto.render_as_job` \R option to control
#'   the default globally.
#'
#' @return Invisibly returns `NULL`. The function is called for its side effect
#'   of rendering the specified document or project.
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
#'
#' # Override metadata
#' quarto_render("notebook.Rmd", metadata = list(lang = "fr", execute = list(echo = FALSE)))
#' }
#' @export
quarto_render <- function(
  input = NULL,
  output_format = NULL,
  output_file = NULL,
  execute = TRUE,
  execute_params = NULL,
  execute_dir = NULL,
  execute_daemon = NULL,
  execute_daemon_restart = FALSE,
  execute_debug = FALSE,
  use_freezer = FALSE,
  cache = NULL,
  cache_refresh = FALSE,
  metadata = NULL,
  metadata_file = NULL,
  debug = FALSE,
  quiet = FALSE,
  profile = NULL,
  quarto_args = NULL,
  pandoc_args = NULL,
  as_job = getOption("quarto.render_as_job", "auto")
) {
  # get quarto binary
  quarto_bin <- find_quarto()

  # provide default for input
  if (is.null(input)) {
    input <- getwd()
  }
  input <- path.expand(input)

  # see if we need to render as a job
  if (identical(as_job, "auto")) {
    as_job <- utils::file_test("-d", input)
  }

  # render as job if requested and running within rstudio
  if (
    as_job &&
      rstudioapi::isAvailable() &&
      rstudioapi::hasFun("runScriptJob") &&
      in_rstudio()
  ) {
    message(
      "Rendering project as background job (use as_job = FALSE to override)"
    )
    script <- tempfile(fileext = ".R")
    render_args <- as.list(sys.call()[-1L])
    render_args <- mapply(
      function(arg, arg_name) {
        paste0(
          arg_name,
          "="[nchar(arg_name) > 0L],
          deparse1(eval(arg, envir = parent.frame(n = 3L)))
        )
      },
      render_args,
      names(render_args)
    )
    writeLines(
      paste0(
        "quarto::quarto_render(",
        paste0(render_args, collapse = ", "),
        ")"
      ),
      script
    )
    rstudioapi::jobRunScript(
      script,
      name = "quarto render",
      workingDir = getwd(),
      importEnv = TRUE
    )
    return(invisible(NULL))
  }

  # build args
  args <- c("render", input)
  if (!missing(output_format)) {
    args <- c(args, "--to", paste(output_format, collapse = ","))
  }
  if (!is.null(output_file)) {
    # handle problem with cli flag
    # https://github.com/quarto-dev/quarto-cli/issues/8399
    # args <- c(args, "--output", output_file)
    metadata[['output-file']] <- output_file
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
  if (isTRUE(use_freezer)) {
    args <- c(args, "--use-freezer")
  }
  if (!missing(cache)) {
    args <- c(args, ifelse(isTRUE(cache), "--cache", "--no-cache"))
  }
  if (isTRUE(cache_refresh)) {
    args <- c(args, "--cache-refresh")
  }
  # metadata to pass to quarto render
  if (!is.null(metadata)) {
    # We merge meta if there is metadata_file passed
    if (!missing(metadata_file)) {
      file_content <- yaml::read_yaml(metadata_file, eval.expr = FALSE)
      metadata <- merge_list(file_content, metadata)
    }
    meta_file <- tempfile(pattern = "quarto-meta", fileext = ".yml")
    on.exit(unlink(meta_file), add = TRUE)
    write_yaml(metadata, meta_file)
    args <- c(args, "--metadata-file", meta_file)
  } else if (!missing(metadata_file)) {
    args <- c(args, "--metadata-file", metadata_file)
  }
  if (isTRUE(debug)) {
    args <- c(args, "--debug")
  }
  if (is_quiet(quiet)) {
    args <- cli_arg_quiet(args)
  }
  if (!is.null(profile)) {
    args <- cli_arg_profile(profile, args)
  }
  if (!is.null(quarto_args)) {
    args <- c(args, quarto_args)
  }
  if (!is.null(pandoc_args)) {
    args <- c(args, pandoc_args)
  }

  # run quarto
  quarto_run(args, echo = TRUE, quarto_bin = quarto_bin)

  # no return value
  invisible(NULL)
}
