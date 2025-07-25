# Use to test quarto availability or version lower than
skip_if_no_quarto <- function(ver = NULL) {
  skip_if(is.null(quarto_path()), message = "Quarto is not available")
  skip_if(
    !quarto_available(min = ver, error = FALSE),
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
  quarto_args = NULL,
  ...,
  .quiet = TRUE,
  .env = parent.frame()
) {
  skip_if_no_quarto()
  skip_if_not_installed("withr")
  # work inside input directory
  withr::local_dir(dirname(input))
  output_file_forced <- NULL
  if (is.null(output_file)) {
    output_file_forced <- basename(withr::local_file(
      xfun::with_ext(input, "test.out"),
      .local_envir = .env
    ))
    # we enforce output file using CLI arg
    quarto_args <- c(
      quarto_args,
      "--output",
      output_file_forced
    )
  } else {
    NULL
  }
  expect_no_error(quarto_render(
    basename(input),
    output_file = output_file,
    quiet = .quiet,
    quarto_args = quarto_args,
    ...
  ))
  out <- output_file %||% output_file_forced
  expect_true(file.exists(out))
  normalizePath(out)
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
  dir_only = FALSE,
  hide_stack = FALSE
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
      if (hide_stack) {
        # Hide possible stack first
        stack_trace_index <- which(grepl("\\s*Stack trace\\:", lines))
        if (
          length(stack_trace_index) > 0 && stack_trace_index < length(lines)
        ) {
          at_lines_indices <- which(grepl("^\\s*at ", lines))
          at_lines_after_stack <- at_lines_indices[
            at_lines_indices > stack_trace_index
          ]
          if (length(at_lines_after_stack) > 0) {
            # Find the continuous sequence (no gaps)
            gaps <- diff(at_lines_after_stack) > 1
            end_pos <- if (any(gaps)) {
              which(gaps)[1]
            } else {
              length(at_lines_after_stack)
            }
            consecutive_indices <- at_lines_after_stack[1:end_pos]

            stack_line <- lines[stack_trace_index]
            indentation <- regmatches(stack_line, regexpr("^\\s*", stack_line))
            lines[consecutive_indices[1]] <- paste0(
              indentation,
              "<stack trace>"
            )
            if (length(consecutive_indices) > 1) {
              lines <- lines[
                -consecutive_indices[2:length(consecutive_indices)]
              ]
            }
          }
        }
      }

      if (full_path) {
        quarto_found <- find_quarto()
        if (dir_only) {
          quarto_found <- dirname(quarto_found)
        }
        quarto_found_normalized <- xfun::normalize_path(quarto_found)
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
  skip_if_not_installed("callr")
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
    skip_if_not_installed("pkgload")
    withr::local_temp_libpaths(.local_envir = .local_envir)
    quick_install(pkgload::pkg_path("."), lib = .libPaths()[1])
    withr::local_envvar(
      R_LIBS = paste0(.libPaths(), collapse = .Platform$path.sep),
      .local_envir = .local_envir
    )
  }
}

local_clean_state <- function(env = parent.frame()) {
  withr::local_envvar(
    # gha debug env variables
    ACTIONS_RUNNER_DEBUG = NA,
    ACTIONS_STEP_DEBUG = NA,
    # quarto R env variables
    R_QUARTO_LOG_DEBUG = NA,
    R_QUARTO_LOG_FILE = NA,
    # quarto CLI env variables
    QUARTO_LOG_LEVEL = NA,
    .local_envir = env
  )
  withr::local_options(
    quarto.log.debug = NULL,
    quarto.log.file = NULL,
    .local_envir = env
  )
}

local_clean_dot_quarto <- function(where = ".", env = parent.frame()) {
  skip_if_not_installed("withr")
  skip_if_not_installed("fs")
  withr::defer(
    {
      # clean up internal .quarto directory
      dot_quarto <- fs::path(where, ".quarto")
      if (fs::dir_exists(dot_quarto)) {
        fs::dir_delete(dot_quarto)
      }
    },
    envir = env
  )
}

resources_path <- function(...) {
  test_path("resources", ...)
}

# Helper function to clean paths from snapshot output
clean_paths_transform <- function(paths_to_clean) {
  function(lines) {
    # Clean each path provided
    for (i in seq_along(paths_to_clean)) {
      path_info <- paths_to_clean[[i]]
      lines <- gsub(
        path_info$actual,
        path_info$replacement,
        lines,
        fixed = TRUE,
      )
    }
    lines
  }
}

single_file_transform <- function(file_path) {
  clean_paths_transform(list(
    list(actual = file_path, replacement = "<test_file>"),
    list(actual = escape_path(file_path), replacement = "<test_file>"),
    list(actual = basename(file_path), replacement = "<test_file_basename>")
  ))
}

escape_path <- function(path) {
  # Escape backslashes in the path for Windows compatibility
  if (.Platform$OS.type == "windows") {
    gsub("\\\\", "\\\\\\\\", path)
  } else {
    path
  }
}
