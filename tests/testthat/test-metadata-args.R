test_that("cli_arg_metadata returns empty args when both inputs NULL", {
  result <- cli_arg_metadata(metadata = NULL, metadata_file = NULL)
  expect_identical(result$args, character())
  expect_null(result$tmp_file)
})

test_that("cli_arg_metadata with metadata only writes temp YAML and uses --metadata-file", {
  skip_if_not_installed("yaml")
  result <- cli_arg_metadata(
    metadata = list(title = "test", lang = "fr"),
    metadata_file = NULL
  )
  withr::defer(unlink(result$tmp_file))

  expect_length(result$args, 2L)
  expect_identical(result$args[1], "--metadata-file")
  expect_true(file.exists(result$args[2]))
  expect_identical(result$args[2], result$tmp_file)

  written <- yaml::read_yaml(result$tmp_file)
  expect_identical(written, list(title = "test", lang = "fr"))
})

test_that("cli_arg_metadata with metadata_file only passes path verbatim", {
  skip_if_not_installed("withr")
  yml <- withr::local_tempfile(fileext = ".yml")
  yaml::write_yaml(list(title = "file-title"), yml)

  result <- cli_arg_metadata(metadata = NULL, metadata_file = yml)
  expect_identical(result$args, c("--metadata-file", yml))
  expect_null(result$tmp_file)
})

test_that("cli_arg_metadata merges metadata over metadata_file with metadata winning", {
  skip_if_not_installed("withr")
  skip_if_not_installed("yaml")
  yml <- withr::local_tempfile(fileext = ".yml")
  yaml::write_yaml(list(title = "from-file", other = "kept"), yml)

  result <- cli_arg_metadata(
    metadata = list(title = "from-list", new = "added"),
    metadata_file = yml
  )
  withr::defer(unlink(result$tmp_file))

  expect_identical(result$args[1], "--metadata-file")
  expect_identical(result$args[2], result$tmp_file)

  written <- yaml::read_yaml(result$tmp_file)
  expect_identical(
    written,
    list(title = "from-list", other = "kept", new = "added")
  )
})

test_that("cli_arg_metadata preserves nested list structure in temp YAML", {
  skip_if_not_installed("yaml")
  nested <- list(format = list(html = list(`toc-title` = "Custom")))
  result <- cli_arg_metadata(metadata = nested, metadata_file = NULL)
  withr::defer(unlink(result$tmp_file))

  written <- yaml::read_yaml(result$tmp_file)
  expect_identical(written, nested)
})

test_that("cli_arg_metadata merge is shallow (top-level keys replaced wholesale)", {
  # Documents current behavior - metadata replaces top-level keys entirely.
  # If we ever switch to deep merge, this test should be updated, not silently broken.
  skip_if_not_installed("yaml")
  yml <- withr::local_tempfile(fileext = ".yml")
  yaml::write_yaml(
    list(format = list(html = list(toc = TRUE, `toc-title` = "Original"))),
    yml
  )

  result <- cli_arg_metadata(
    metadata = list(format = list(html = list(`toc-title` = "Overridden"))),
    metadata_file = yml
  )
  withr::defer(unlink(result$tmp_file))

  written <- yaml::read_yaml(result$tmp_file)
  # toc=TRUE from file is LOST because metadata's `format` replaces wholesale
  expect_identical(
    written,
    list(format = list(html = list(`toc-title` = "Overridden")))
  )
})
