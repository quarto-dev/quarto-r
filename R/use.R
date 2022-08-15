#' Quarto Use Template
#'
#' Install and use a template into a Quarto project.
#'
#' @param template The template to install, either an archive or a GitHub
#'   repository as described in the documentation
#'   <https://quarto.org/docs/extensions/formats.html>.
#'
#' @examples
#' \dontrun{
#' # Install a template and set up a draft document from a GitHub repository
#' quarto_use_template("quarto-journals/jss")
#'
#' # Install a template and set up a draft document from a ZIP archive
#' quarto_use_template("https://github.com/quarto-journals/jss/archive/refs/heads/main.zip")
#' }
#'
#' @export
quarto_use_template <- function(template = NULL) {
  quarto_bin <- find_quarto()
  message(
    "Quarto templates may execute code when documents are rendered. ",
    "If you do not trust the authors of the template, ",
    "we recommend that you do not install or use the template."
  )
  prompt_value <- tolower(readline("Do you trust the authors of this template (Y/n)? "))
  if (!prompt_value %in% "y") {
    message("Quarto template not installed.")
    return(invisible())
  }

  tryCatch(
    system2(quarto_bin, stdout = TRUE, c(
      "use",
      "template",
      "--no-prompt",
      template
    )),
    error = function(e) e,
    warning = function(w) w
  )
  invisible()
}
