# Use to test quarto availability or version lower than
skip_if_no_quarto <- function(ver = NULL) {
  skip_if(is.null(quarto_path()), message = "Quarto is not available")
  skip_if(
    quarto_version() < ver,
    message = sprintf("Version of quarto is lower than %s.", ver)
  )
}

# Use to test quarto  greater than
skip_if_quarto <- function(ver = NULL) {
  if (is.null(ver)) {
    skip_if(!is.null(quarto_path()), message = "Quarto is available")
  } else {
    skip_if(
      quarto_version() >= ver,
      message = sprintf("Version of quarto is greater than or equal %s.", ver)
    )
  }
}

local_qmd_file <- function(..., .env = parent.frame()) {
  skip_if_not_installed("xfun")
  skip_if_not_installed("withr")
  # create a directory to delete for correct cleaning
  dir <- withr::local_tempdir("quarto-test", .local_envir = .env)
  # create a file in this directory
  path <- withr::local_tempfile(tmpdir = dir, fileext = ".qmd", .local_envir = .env)
  xfun::write_utf8(c(...), path)
  path
}

local_quarto_project <- function(..., yml = list(project = list(type = "default")), .env = parent.frame()) {
  skip_if_not_installed("withr")
  skip_if_not_installed("yaml")
  # Create a directory and a .qmd file
  path <- local_qmd_file(..., .env = .env)
  withr::local_dir(project <- dirname(path))
  write_yaml(yml, "_quarto.yml")
  # return the project dir
  project
}

.render <- function(input, output_file = NULL, ..., .env = parent.frame()) {
  skip_if_no_quarto()
  skip_if_not_installed("withr")
  # work inside input directory
  withr::local_dir(dirname(input))
  if (is.null(output_file)) {
    output_file <- basename(withr::local_file(
      xfun::with_ext(input, "test.out"),
      .local_envir = .env
    ))
  }
  quarto_render(basename(input), output_file = output_file, quiet = TRUE, ...)
  expect_true(file.exists(output_file))
  normalizePath(output_file)
}

.render_and_read <- function(input, ...) {
  skip_if_not_installed("xfun")
  skip_if_not_installed("withr")
  out <- .render(input, ...)
  xfun::read_utf8(out)
}

expect_snapshot_qmd_output <- function(name, input, output_file = NULL, ...) {
  local_edition(3)
  skip_if_not_installed("xfun")
  name <- xfun::with_ext(name, ".test.out")

  # Announce the file before touching `code`. This way, if `code`
  # unexpectedly fails or skips, testthat will not auto-delete the
  # corresponding snapshot file.
  announce_snapshot_file(name = name)

  # render with quarto and snapshot
  output_file <- .render(input, output_file, ...)

  expect_snapshot_file(output_file, name)
}


transform_quarto_cli_in_output <- function(full_path = FALSE) {
  return(
    function(lines) {
      if (full_path) {
        gsub(find_quarto(), "<quarto full path>", lines, fixed = TRUE)
      } else {
        # it will be quarto.exe only on windows
        gsub("quarto.exe", "quarto", lines)
      }
    }
  )
}
