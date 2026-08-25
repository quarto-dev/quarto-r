test_that("hex_encode() round-trips through rmd-init.R decoding", {
  # mirror of the decoding in inst/rmd-init.R
  hex_decode <- function(hex) {
    bytes <- as.raw(strtoi(
      substring(hex, seq(1L, nchar(hex), 2L), seq(2L, nchar(hex), 2L)),
      16L
    ))
    x <- rawToChar(bytes)
    Encoding(x) <- "UTF-8"
    x
  }
  libs <- paste(
    c("/tmp/lib with spaces", "/tmp/lib-éü"),
    collapse = .Platform$path.sep
  )
  encoded <- hex_encode(libs)
  # payload is comma-free pure ASCII (safe for QUARTO_KNITR_RSCRIPT_ARGS)
  expect_true(grepl("^[0-9a-f]*$", encoded))
  expect_identical(hex_decode(encoded), enc2utf8(libs))
})

test_that("knitr_rscript_args() builds init script + hex payload", {
  skip_on_cran()
  withr::local_envvar(QUARTO_KNITR_RSCRIPT_ARGS = NA)
  parts <- strsplit(
    knitr_rscript_args("C:/R/library"),
    ",",
    fixed = TRUE
  )[[1L]]
  expect_length(parts, 2L)
  expect_match(parts[1L], "rmd-init\\.R$")
  expect_identical(parts[2L], hex_encode("C:/R/library"))
})

test_that("knitr_rscript_args() preserves user-set QUARTO_KNITR_RSCRIPT_ARGS", {
  skip_on_cran()
  withr::local_envvar(
    QUARTO_KNITR_RSCRIPT_ARGS = "--vanilla,--no-init-file"
  )
  parts <- strsplit(
    knitr_rscript_args("C:/R/library"),
    ",",
    fixed = TRUE
  )[[1L]]
  # user args stay first so they remain before the script position
  expect_identical(parts[1:2], c("--vanilla", "--no-init-file"))
  expect_length(parts, 4L)
})

test_that("rmd-init.R restores .libPaths() and sources the engine script", {
  skip_on_cran()
  init_script <- system.file("rmd-init.R", package = "quarto")
  skip_if_not(nzchar(init_script))
  tmp_lib <- withr::local_tempdir("tmp_libpath")
  probe <- withr::local_tempfile(fileext = ".R")
  writeLines('cat(.libPaths(), sep = "\n")', probe)
  libs <- paste(c(tmp_lib, .libPaths()), collapse = .Platform$path.sep)
  out <- processx::run(
    file.path(R.home("bin"), "Rscript"),
    args = c(init_script, hex_encode(libs), probe)
  )$stdout
  expect_match(out, basename(tmp_lib), fixed = TRUE)
})
