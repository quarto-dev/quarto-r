test_that("quarto_version returns a numeric version", {
  skip_if_no_quarto()
  expect_s3_class(quarto_version(), "numeric_version")
})

test_that("quarto_run gives guidance in error", {
  # we need to skip previous versions because 1.5.41 introduced an issue solved completely in 1.5.56
  skip_if_quarto_between("1.5.41", "1.5.55")
  local_reproducible_output(width = 1000)
  expect_snapshot(
    error = TRUE,
    quarto_run(c("rend", "--quiet")),
    transform = transform_quarto_cli_in_output()
  )
})

test_that("quarto_run report full quarto cli error message", {
  skip_if_no_quarto()
  local_reproducible_output(width = 1000)
  # Ensure we don't have colors in the output for quarto-cli error
  withr::local_envvar(list(NO_COLOR = 1L))
  # https://github.com/quarto-dev/quarto-r/issues/235
  tmp_proj <- local_quarto_project(type = "book")
  withr::local_dir(tmp_proj)
  # simulate an error by renaming the intro.qmd
  file.rename(from = "intro.qmd", to = "no_intro.qmd")
  expect_snapshot(
    error = TRUE,
    quarto_inspect(),
    transform = transform_quarto_cli_in_output(
      full_path = TRUE,
      dir_only = TRUE,
      hide_stack = TRUE
    )
  )
})

test_that("is_using_quarto correctly check directory", {
  qmd <- local_qmd_file(c("content"))
  # Only qmd
  expect_true(is_using_quarto(dirname(qmd)))
  expect_snapshot(is_using_quarto(dirname(qmd), verbose = TRUE))
  # qmd and _quarto.yml
  write_yaml(
    list(project = list(type = "default")),
    file = file.path(dirname(qmd), "_quarto.yml")
  )
  expect_true(is_using_quarto(dirname(qmd)))
  expect_snapshot(is_using_quarto(dirname(qmd), verbose = TRUE))
  # Only _quarto.yml
  unlink(qmd)
  expect_true(is_using_quarto(dirname(qmd)))
  expect_snapshot(is_using_quarto(dirname(qmd), verbose = TRUE))
  # Empty dir
  unlink(file.path(dirname(qmd), "_quarto.yml"))
  expect_false(is_using_quarto(dirname(qmd)))
  expect_snapshot(is_using_quarto(dirname(qmd), verbose = TRUE))
  # Non empty dir
  withr::local_dir(dirname(qmd))
  withr::local_file("test.txt")
})

test_that("quarto CLI sitrep", {
  skip_if_no_quarto()
  skip_on_cran()
  local_reproducible_output(width = 1000)
  dummy_quarto_path <- xfun::normalize_path("dummy")
  withr::with_envvar(
    list(QUARTO_PATH = dummy_quarto_path, RSTUDIO_QUARTO = NA),
    expect_snapshot(
      quarto_binary_sitrep(debug = TRUE),
      transform = function(lines) {
        gsub(dummy_quarto_path, "<QUARTO_PATH path>", lines, fixed = TRUE)
      }
    )
  )
  withr::with_envvar(
    list(QUARTO_PATH = NA, RSTUDIO_QUARTO = dummy_quarto_path),
    expect_snapshot(
      quarto_binary_sitrep(debug = TRUE),
      transform = function(lines) {
        lines <- gsub(
          dummy_quarto_path,
          "<RSTUDIO_QUARTO path>",
          lines,
          fixed = TRUE
        )
        transform_quarto_cli_in_output(full_path = TRUE)(
          lines
        )
      }
    )
  )

  withr::with_envvar(
    list(QUARTO_PATH = NA, RSTUDIO_QUARTO = NA),
    expect_snapshot(
      quarto_binary_sitrep(debug = TRUE),
      transform = transform_quarto_cli_in_output(
        full_path = TRUE
      )
    )
  )

  # Mock no quarto found
  with_mocked_bindings(
    quarto_path = function(...) NULL,
    expect_snapshot(
      quarto_binary_sitrep(debug = TRUE)
    )
  )
})


test_that("quarto.quiet options controls echo and overwrite function argument", {
  skip_if_no_quarto()
  skip_on_cran()
  qmd <- local_qmd_file("content")
  withr::with_options(list(quarto.quiet = TRUE), {
    expect_output(quarto_render(qmd, quiet = FALSE), regexp = NA)
  })
  withr::with_options(list(quarto.quiet = FALSE), {
    expect_output(quarto_render(qmd, quiet = TRUE))
  })
})

test_that("quarto_available()", {
  expect_error(
    quarto_available("1.5", "1.4"),
    regexp = "Minimum version .* cannot be greater than maximum version .*"
  )

  # Mock no quarto found
  with_mocked_bindings(
    quarto_version = function(...) NULL,
    {
      expect_false(quarto_available())
      expect_error(quarto_available(error = TRUE))
    }
  )

  local_mocked_bindings(
    quarto_version = function(...) as.numeric_version("1.8.4")
  )

  expect_true(quarto_available())
  expect_true(quarto_available("1", "2"))
  expect_false(quarto_available(max = "1.5"))
  expect_error(
    quarto_available(max = "1.6", error = TRUE),
    regexp = "Maximum version expected is 1.6"
  )
  expect_true(quarto_available(min = "1.8.4"))
  expect_false(quarto_available(min = "1.9.5"))
  expect_error(
    quarto_available(min = "1.9.5", error = TRUE),
    regexp = "Minimum version expected is 1.9.5"
  )
})
