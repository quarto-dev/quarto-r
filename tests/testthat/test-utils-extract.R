test_that("extract_r_code() errors on wrong qmd", {
  expect_snapshot(
    error = TRUE,
    extract_r_code("nonexistent.qmd")
  )
})

test_that("extract_r_code() writes metadata", {
  skip_if_no_quarto()
  r_script <- withr::local_tempfile(pattern = "purl", fileext = ".R")

  announce_snapshot_file(name = "purl.R")
  expect_snapshot_file(
    path = extract_r_code(test_path("docs", "purl-r.qmd"), script = r_script),
    name = "purl.R"
  )
})

test_that("extract_r_code() do nothing on file with no code", {
  skip_if_no_quarto()
  expect_message(
    expect_null(extract_r_code(test_path("docs", "purl-no-cell.qmd"))),
    "No code cells found"
  )
  expect_false(file.exists(test_path("docs", "purl.R")))
})

test_that("extract_r_code() do nothing on file with only other language code", {
  skip_if_no_quarto()
  expect_message(
    expect_null(extract_r_code(test_path("docs", "purl-py.qmd"))),
    "No R code cells found.*: python"
  )
  expect_false(file.exists(test_path("docs", "purl.R")))
})
