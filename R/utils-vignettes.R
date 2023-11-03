register_vignette_engines <- function(pkg) {
  vig_engine("html", quarto_format = "html")
  vig_engine("pdf", quarto_format = "pdf")
}


vig_engine <- function(..., quarto_format) {
  rmd_eng <- tools::vignetteEngine('rmarkdown', package = 'knitr')
  tools::vignetteEngine(
    ...,
    weave = vweave_quarto(quarto_format),
    tangle = rmd_eng$tangle,
    pattern = "[.]qmd$",
    package = "quarto",
    aspell = rmd_eng$aspell
  )
}

vweave_quarto <- function(format) {
  meta <- list()
  meta["embed-resources"] <- TRUE
  function(file, driver, syntax, encoding, quiet = FALSE, ...) {
    quarto_render(file, ..., output_format = format, metadata = meta)
  }
}
