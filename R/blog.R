#' Create a new blog post
#'
#' Creates (and potentially opens) the `index.qmd` file for a new blog post.
#'
#' @inheritParams rlang::args_error_context
#' @param title A character string for the title of the post. It is converted
#' to title case via [tools::toTitleCase()].
#' @param dest A character string (or NULL) for the path within `posts`. By
#' default, the title is adapted as the directory name.
#' @param wd An optional working directory. If `NULL`, the current working is used.
#' @param open A logical: have the default editor open a window to edit the
#' `index.qmd` file?
#' @param ... A named list of values to be added to the yaml header, such as
#' `date`, `author`, `categories`, `description`, etc.
#' If no `date` is provided, the current date is used.
#' If no `author` is provided, `whoami::fullname()` is used to get the user's name.
#' @return The path to the index file.
#' @export
#' @examples
#' \dontrun{\donttest{
#' new_blog_post("making quarto blog posts", categories = c("R"))
#' }}
#'
new_blog_post <- function(
  title,
  dest = NULL,
  wd = NULL,
  open = rlang::is_interactive(),
  call = rlang::current_env(),
  ...
) {
  rlang::check_installed("whoami")

  if (is.null(dest)) {
    # Scrub title to make directory name
    dest <- gsub("[[:space:]]", "-", tolower(title))
  }
  dest_path <- make_post_dir(dest, wd, call)
  post_yaml <- make_post_yaml(title, ...)
  qmd_path <- write_post_yaml(post_yaml, dest_path, call)
  if (open) {
    edit_file <- utils::file.edit
    if (
      rlang::is_installed("usethis") &&
        is.function(asNamespace("usethis")$edit_file)
    ) {
      edit_file <- utils::getFromNamespace("edit_file", "usethis")
    }
    edit_file(qmd_path)
  }
  invisible(qmd_path)
}

make_post_dir <- function(dest, wd, call) {
  working <- if (is.null(wd)) fs::path_wd() else fs::path_abs(wd)

  # is this a quarto project for blog ? Expecting _quarto.yml in working dir
  if (!fs::file_exists(fs::path(working, "_quarto.yml"))) {
    cli::cli_abort(
      "You need to be at root of a Quarto project to create a blog post in the {.file posts/} directory at {.file {fs::path_real(working)}}.",
      call = call
    )
  }

  post_path <- fs::path(working, "posts", dest)

  if (fs::dir_exists(post_path)) {
    cli::cli_abort(
      "There is already a {.file {dest}} directory in 'posts/'",
      call = call
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

  yml_values <- merge_list(default_values, user_values)
  if (length(yml_values$categories) == 0) {
    yml_values <- yml_values[names(yml_values) != "categories"]
  }
  yml_values <- as_yaml_block(yml_values)
  yml_values
}

write_post_yaml <- function(x, dest, call) {
  dest_file <- fs::path(dest, "index.qmd")
  if (fs::file_exists(dest_file)) {
    cli::cli_abort(
      "There is already am index.qmd file at {.code {path}}",
      call = call
    )
  } else {
    ret <- xfun::write_utf8(x, con = dest_file)
  }
  dest_file
}
