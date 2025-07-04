# file specific helpers ----
create_test_script <- function(
  name,
  content = c("x <- 1", "y <- 2"),
  envir = rlang::caller_env()
) {
  tmp_dir <- withr::local_tempdir(.local_envir = envir)
  withr::local_dir(tmp_dir, .local_envir = envir)
  script <- name
  xfun::write_utf8(content, script)
  script
}

expect_preamble_added <- function(script, snapshot_name) {
  expect_message(
    result <- add_spin_preamble(script),
    "Added spin preamble"
  )
  expect_equal(result, script)

  announce_snapshot_file(name = snapshot_name)
  expect_snapshot_file(script, snapshot_name)
}

# Tests ----

test_that("add_spin_preamble checks for file existence", {
  expect_snapshot(
    error = TRUE,
    add_spin_preamble("non_existent_file.R")
  )
})

test_that("add_spin_preamble adds preamble to file without one", {
  script <- create_test_script("report.R")
  expect_preamble_added(script, "spin_preamble.R")

  skip_on_cran()
  skip_if_no_quarto("1.4.511")
  expect_no_error(quarto_render(script, quiet = TRUE))
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
  script <- create_test_script("report.R", "")
  expect_preamble_added(script, "spin_preamble-empty.R")
})

test_that("add_spin_preamble works with custom title", {
  script <- create_test_script("analysis.R")

  expect_message(
    result <- add_spin_preamble(script, title = "Custom Analysis"),
    "Added spin preamble"
  )
  expect_equal(result, script)

  announce_snapshot_file(name = "spin_preamble-custom-title.R")
  expect_snapshot_file(script, "spin_preamble-custom-title.R")
})

test_that("add_spin_preamble works with custom preamble", {
  script <- create_test_script("report.R", c("library(ggplot2)", "plot(1:10)"))

  expect_message(
    result <- add_spin_preamble(
      script,
      preamble = list(
        title = "My Report",
        author = "John Doe",
        format = "html"
      )
    ),
    "Added spin preamble"
  )
  expect_equal(result, script)

  announce_snapshot_file(name = "spin_preamble-custom-preamble.R")
  expect_snapshot_file(script, "spin_preamble-custom-preamble.R")
})

test_that("title parameter overrides preamble title", {
  script <- create_test_script("override.R", "x <- 1")

  expect_message(
    result <- add_spin_preamble(
      script,
      title = "Override Title",
      preamble = list(title = "Original Title", author = "John Doe")
    ),
    "Added spin preamble"
  )
  expect_equal(result, script)

  announce_snapshot_file(name = "spin_preamble-title-override.R")
  expect_snapshot_file(script, "spin_preamble-title-override.R")
})

test_that("preamble title is used when title parameter is NULL", {
  script <- create_test_script("preamble_title.R", "x <- 1")

  expect_message(
    result <- add_spin_preamble(
      script,
      title = NULL,
      preamble = list(title = "Preamble Title", author = "Jane Doe")
    ),
    "Added spin preamble"
  )
  expect_equal(result, script)

  announce_snapshot_file(name = "spin_preamble-preamble-title.R")
  expect_snapshot_file(script, "spin_preamble-preamble-title.R")
})

test_that("add_spin_preamble validates preamble argument", {
  tmp_file <- withr::local_tempfile(fileext = ".R")
  writeLines("x <- 1", tmp_file)

  expect_snapshot(
    error = TRUE,
    add_spin_preamble(tmp_file, preamble = "not a list")
  )
})

test_that("build_preamble() splits and preprends", {
  expect_identical(build_preamble("XXX", "A"), "XXX A")
  expect_identical(build_preamble("XXX", "A\nB"), c("XXX A", "XXX B"))
})

test_that("build_preamble() handles empty content", {
  expect_identical(build_preamble("XXX", ""), "")
})

test_that("create_header_preamble() handles empty metadata", {
  expect_identical(create_header_preamble(list()), "")
})

test_that("create_header_preamble() creates correct YAML header", {
  metadata <- list(
    title = "Test Document",
    author = "Jane Doe",
    date = "2023-10-01"
  )
  expect_identical(
    create_header_preamble(metadata),
    c(
      "#' ---",
      "#' title: Test Document",
      "#' author: Jane Doe",
      "#' date: '2023-10-01'",
      "#' ---",
      "#' "
    )
  )
})

test_that("create_code_preamble() handles empty metadata", {
  expect_identical(create_code_preamble(list()), "")
})

test_that("create_code_preamble() creates correct code comments", {
  metadata <- list(
    echo = TRUE,
    eval = FALSE
  )
  expect_identical(
    create_code_preamble(metadata),
    c("#| echo: true", "#| eval: false")
  )
})
