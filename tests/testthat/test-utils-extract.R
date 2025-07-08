test_that("qmd_to_r_script() errors on wrong qmd", {
  expect_snapshot(
    error = TRUE,
    qmd_to_r_script("nonexistent.qmd")
  )
})

test_that("qmd_to_r_script() errors on existing script", {
  r_script <- withr::local_tempfile(pattern = "purl", fileext = ".R")
  file.create(r_script)
  expect_snapshot(
    error = TRUE,
    qmd_to_r_script(resources_path("purl-r.qmd"), script = r_script),
    transform = function(x) {
      gsub("(! File ).*( already exists.)", "\\1<r script>\\2", x)
    }
  )
})

test_that("qmd_to_r_script() writes R file that renders", {
  skip_if_no_quarto()
  r_script <- withr::local_tempfile(pattern = "purl", fileext = ".R")

  announce_snapshot_file(name = "purl.R")

  expect_snapshot_file(
    path = qmd_to_r_script(
      resources_path("purl-r.qmd"),
      script = r_script
    ),
    name = "purl.R"
  )

  skip_if_no_quarto("1.4.511")
  announce_snapshot_file(name = "purl.md")
  md_file <- xfun::with_ext(r_script, "md")
  quarto::quarto_render(
    r_script,
    output_format = "markdown",
    output_file = basename(md_file),
    quiet = TRUE
  )
  expect_snapshot_file(
    path = md_file,
    name = "purl.md"
  )
})

test_that("qmd_to_r_script() do nothing on file with no code", {
  skip_if_no_quarto()
  expect_message(
    expect_null(qmd_to_r_script(resources_path("purl-no-cell.qmd"))),
    "No code cells found"
  )
  expect_false(file.exists(resources_path("purl.R")))
})

test_that("qmd_to_r_script() do nothing on file with only other language code", {
  skip_if_no_quarto()
  expect_message(
    expect_null(qmd_to_r_script(resources_path("purl-py.qmd"))),
    "No R code cells found.*: python"
  )
  expect_false(file.exists(resources_path("purl.R")))
})

test_that("qmd_to_r_script() ignore other language code", {
  skip_if_no_quarto()
  r_script <- withr::local_tempfile(pattern = "purl", fileext = ".R")
  expect_snapshot(
    qmd_to_r_script(resources_path("purl-r-ojs.qmd"), r_script),
  )
  expect_true(file.exists(r_script))
})
