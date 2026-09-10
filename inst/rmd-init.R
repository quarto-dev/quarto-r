# Entry point injected into the Rscript command line on Windows via
# QUARTO_KNITR_RSCRIPT_ARGS. Restores .libPaths() from the hex-encoded
# trailing argument, then sources Quarto's knitr engine script (which Quarto
# CLI appends to the command line immediately after the hex payload).
# Needed because environment variables are not inherited by the Rscript
# process spawned by quarto.exe on Windows.
# https://github.com/quarto-dev/quarto-r/issues/217
local({
  args <- commandArgs(trailingOnly = TRUE)
  hex <- args[[1L]]
  bytes <- as.raw(strtoi(
    substring(hex, seq(1L, nchar(hex), 2L), seq(2L, nchar(hex), 2L)),
    16L
  ))
  libs <- rawToChar(bytes)
  Encoding(libs) <- "UTF-8"
  .libPaths(strsplit(libs, .Platform$path.sep, fixed = TRUE)[[1L]])
  source(args[[2L]]) # default local = FALSE evaluates in .GlobalEnv
})
