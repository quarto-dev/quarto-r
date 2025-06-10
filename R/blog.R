#' Create a new blog post
#'
#' Creates (and potentially opens) the `index.qmd` file for a new blog post.
#'
#' @param title A character string for the title of the post. It is converted
#' to title case via [tools::toTitleCase()].
#' @param dest A character string (or NULL) for the path within `posts`. By
#' default, the title is adapted as the directory name.
#' @param open A logical: have the default editor open a window to edit the
#' `index.qmd` file?
#' @param call A call object for reporting errors.
#' @param ... A named list of values to be added to the yaml header, such as
#' `description`, `author`, `categories`, etc.
#' @return The path to the index file.
#' @export
#' @examples
#' \dontrun{
#'  \donttest{
#' new_blog_post("making quarto blog posts", categories = c("R"))
#'
#'  }
#' }
#'
new_blog_post <- function(
  title,
  dest = NULL,
  open = rlang::is_interactive(),
  .call = rlang::current_env(),
  ...
) {
  rlang::check_installed("whoami")

  if (is.null(dest)) {
    # Scrub title to make directory name
    dest <- gsub("[[:space:]]", "-", tolower(title))
  }
  dest_path <- make_post_dir(dest, .call)
  post_yaml <- make_post_yaml(title, ...)
  qmd_path <- write_post_yaml(post_yaml, dest_path, .call)
  if (open) {
    edit_file <- utils::file.edit
    if (
      rlang::is_installed("usethis") && rlang::is_callable(usethis::edit_file)
    ) {
      edit_file <- getFromNamespace("edit_file", "usethis")
    }
    edit_file(qmd_path)
  }
  invisible(qmd_path)
}

make_post_dir <- function(dest, .call) {
  working <- fs::path_wd()

  post_path <- fs::path(working, "posts", dest)

  if (fs::dir_exists(post_path)) {
    cli::cli_abort(
      "There is already a {.file {dest}} directory in 'posts/'",
      call = .call
    )
  } else {
    ret <- fs::dir_create(post_path)
  }
  ret
}

make_post_yaml <- function(title, ...) {
  default_values <- list(
    title = tools::toTitleCase(title),
    author = tools::toTitleCase(whoami::fullname("Your name")),
    date = format(Sys.Date(), "%Y-%m-%d"),
    categories = character(0)
  )

  user_values <- list(...)

  yml_values <- utils::modifyList(default_values, user_values)
  if (length(yml_values$categories) == 0) {
    yml_values <- yml_values[names(yml_values) != "categories"]
  }
  yml_values <- yaml::as.yaml(yml_values)
  yml_values <- paste0("---\n", yml_values, "---\n")
  yml_values
}

write_post_yaml <- function(x, dest, .call) {
  dest_file <- fs::path(dest, "index.qmd")
  if (fs::file_exists(dest_file)) {
    cli::cli_abort(
      "There is already am index.qmd file at {.code {path}}",
      call = .call
    )
  } else {
    ret <- cat(x, file = dest_file)
  }
  dest_file
}
