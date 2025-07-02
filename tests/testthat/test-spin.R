test_that("add_spin_preamble checks for file existence", {
  expect_snapshot(
    error = TRUE,
    add_spin_preamble("non_existent_file.R")
  )
})

test_that("add_spin_preamble adds preamble to file without one", {
  # Create temporary file
  tmp_dir <- withr::local_tempdir()
  withr::local_dir(tmp_dir)
  script <- "report.R"
  writeLines(c("x <- 1", "y <- 2"), script)

  # Add preamble
  expect_message(
    result <- add_spin_preamble(script),
    "Added spin preamble"
  )

  # Check return value
  expect_equal(result, script)

  announce_snapshot_file(name = "spin_preamble.R")
  expect_snapshot_file(script, "spin_preamble.R")

  skip_on_cran()
  skip_if_no_quarto("1.4.511")
  expect_no_error(
    quarto_render(script, quiet = TRUE)
  )
  expect_true(file.exists(xfun::with_ext(script, "html")))
})

test_that("add_spin_preamble doesn't modify file with existing preamble", {
  # Create file with existing preamble
  tmp_file <- withr::local_tempfile(fileext = ".R")
  original_content <- c(
    "#' ---",
    "#' title: \"Existing Title\"",
    "#' ---",
    "#' ",
    "x <- 1"
  )
  xfun::write_utf8(original_content, tmp_file)

  # Try to add preamble
  expect_message(
    result <- add_spin_preamble(tmp_file),
    "already has a spin preamble"
  )

  # Check return value is invisible
  expect_invisible(expect_null(result))

  # Check content unchanged
  new_content <- xfun::read_utf8(tmp_file)
  expect_equal(new_content, original_content)
})

test_that("add_spin_preamble detects preamble with leading whitespace", {
  # Create file with preamble that has leading whitespace
  tmp_file <- withr::local_tempfile(fileext = ".R")
  original_content <- c(
    "  #' This is a comment",
    "x <- 1"
  )
  xfun::write_utf8(original_content, tmp_file)

  expect_message(
    add_spin_preamble(tmp_file),
    "already has a spin preamble"
  )

  # Content should be unchanged
  new_content <- xfun::read_utf8(tmp_file)
  expect_equal(new_content, original_content)
})

test_that("add_spin_preamble works with empty file", {
  tmp_dir <- withr::local_tempdir()
  withr::local_dir(tmp_dir)
  script <- "report.R"
  writeLines("", script) # Empty file

  # Add preamble
  expect_message(
    result <- add_spin_preamble(script),
    "Added spin preamble"
  )

  # Check return value
  expect_equal(result, script)

  announce_snapshot_file(name = "spin_preamble-empty.R")
  expect_snapshot_file(script, "spin_preamble-empty.R")
})
