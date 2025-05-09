# Use to test quarto availability or version lower than
skip_if_no_quarto <- function(ver = NULL) {
  skip_if(is.null(quarto_path()), message = "Quarto is not available")
  skip_if(
    quarto_version() < ver,
    message = sprintf(
      "Version of quarto is lower than %s: %s.",
      ver,
      quarto_version()
    )
  )
}

# Use to test quarto greater than
skip_if_quarto <- function(ver = NULL) {
  # Skip if no quarto available
  skip_if_no_quarto()
  # Then skip if available or if version is greater than
  if (is.null(ver)) {
    skip_if(
      !is.null(quarto_path()),
      message = sprintf("Quarto is available: %s.", quarto_version())
    )
  } else {
    skip_if(
      quarto_version() >= ver,
      message = sprintf(
        "Version of quarto is greater than or equal %s: %s.",
        ver,
        quarto_version()
      )
    )
  }
}

skip_if_quarto_between <- function(min, max) {
  # Skip if no quarto available
  skip_if_no_quarto()
  # Then skip if available or if version is greater than
  skip_if(
    quarto_version() >= min && quarto_version() <= max,
    message = sprintf(
      "Version of quarto is between %s and %s: %s",
      min,
      max,
      quarto_version()
    )
  )
}

local_qmd_file <- function(..., .env = parent.frame()) {
  skip_if_not_installed("xfun")
  skip_if_not_installed("withr")
  # create a directory to delete for correct cleaning
  dir <- withr::local_tempdir("quarto-test", .local_envir = .env)
  # create a file in this directory
  path <- withr::local_tempfile(
    tmpdir = dir,
    fileext = ".qmd",
    .local_envir = .env
  )
  xfun::write_utf8(c(...), path)
  path
}

local_quarto_project <- function(
  name = "test-project",
  type,
  ...,
  .env = parent.frame()
) {
  skip_if_no_quarto()
  path_tmp <- withr::local_tempdir(
    pattern = "quarto-tests-project-",
    .local_envir = .env
  )
  tryCatch(
    quarto_create_project(
      name = name,
      type = type,
      dir = path_tmp,
      no_prompt = TRUE,
      quiet = TRUE,
      ...
    ),
    error = function(e) {
      stop("Creating temp project for tests failed", call. = FALSE)
    }
  )
  # return the path to the created project
  return(file.path(path_tmp, name))
}

.render <- function(
  input,
  output_file = NULL,
  ...,
  .quiet = TRUE,
  .env = parent.frame()
) {
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
  expect_no_error(quarto_render(
    basename(input),
    output_file = output_file,
    quiet = .quiet,
    ...
  ))
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


transform_quarto_cli_in_output <- function(
  full_path = FALSE,
  version = FALSE,
  dir_only = FALSE
) {
  hide_path <- function(lines, real_path) {
    gsub(
      real_path,
      "<quarto full path>",
      lines,
      fixed = TRUE
    )
  }

  return(
    function(lines) {
      if (full_path) {
        quarto_found <- find_quarto()
        if (dir_only) {
          quarto_found <- dirname(quarto_found)
        }
        quarto_found_normalized <- normalizePath(quarto_found, mustWork = FALSE)
        # look for non-normalized path
        lines <- hide_path(lines, quarto_found)
        # look for normalized path
        lines <- hide_path(lines, quarto_found_normalized)

        non_normalized_path <- quarto_path(normalize = FALSE)
        non_normalized_path_slash <- gsub("\\\\", "/", non_normalized_path)
        lines <- hide_path(lines, non_normalized_path)
        lines <- hide_path(lines, non_normalized_path_slash)

        # seems like there are quotes around path in CI windows
        lines <- gsub(
          "\"<quarto full path>([^\"]*)\"",
          "<quarto full path>\\1",
          lines
        )

        # Handle quarto.js in stackstrace outputs
        lines <- gsub(
          "file:[/]{2,3}<quarto full path>[/\\]quarto.js:\\d+:\\d+",
          "<quarto.js full path with location>",
          lines
        )
        # fixup binary name difference it exists in the output
        # windows is quarto.exe while quarto on other OS
        lines <- gsub("quarto.exe", "quarto", lines, fixed = TRUE)
      } else {
        # it will be quarto.exe only on windows
        lines <- gsub("quarto\\.(exe|cmd)", "quarto", lines)
      }

      # fallback: Above can fail on some windows situation, so try a regex match
      # it should only match windows path with Drive letters
      lines <- gsub(
        "file:[/]{2,3}[A-Za-z]:[\\\\/](?:[^:\\n]+[\\\\/])*bin[\\\\/]quarto\\.js:\\d+:\\d+",
        "<quarto.js full path with location>",
        lines,
        perl = TRUE
      )

      if (version) {
        lines <- gsub(quarto_version(), "<quarto version>", lines, fixed = TRUE)
      }
      return(lines)
    }
  )
}


local_quarto_run_echo_cmd <- function(.env = parent.frame()) {
  if (rlang::is_installed("withr")) {
    withr::local_options(quarto.echo_cmd = TRUE, .local_envir = .env)
  }
}

quick_install <- function(package, lib, quiet = TRUE) {
  opts <- c(
    "--data-compress=none",
    "--no-byte-compile",
    "--no-data",
    "--no-demo",
    "--no-docs",
    "--no-help",
    "--no-html",
    "--no-libs",
    "--use-vanilla",
    sprintf("--library=%s", lib),
    package
  )
  invisible(callr::rcmd("INSTALL", opts, show = !quiet, fail_on_status = TRUE))
}

install_dev_package <- function(.local_envir = parent.frame()) {
  # if not inside of R CMD check, install dev version into temp directory
  if (Sys.getenv("_R_CHECK_TIMINGS_") == "") {
    withr::local_temp_libpaths(.local_envir = .local_envir)
    quick_install(pkgload::pkg_path("."), lib = .libPaths()[1])
    withr::local_envvar(
      R_LIBS = paste0(.libPaths(), collapse = .Platform$path.sep),
      .local_envir = .local_envir
    )
  }
}
