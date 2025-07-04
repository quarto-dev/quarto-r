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
    path = extract_r_code(test_path("docs", "purl.qmd"), script = r_script),
    name = "purl.R"
  )
})
