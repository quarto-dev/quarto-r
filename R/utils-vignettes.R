register_vignette_engines <- function(pkg) {
  vig_engine("html", quarto_format = "html")
  vig_engine("pdf", quarto_format = "pdf")
  vig_engine("format", quarto_format = NULL)
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
  meta <- get_meta(format)
  function(file, driver, syntax, encoding, quiet = FALSE, ...) {
    quarto_render(file, ..., output_format = format, metadata = meta)
  }
}

get_meta <- function(format) {
  if (is.null(format)) return(NULL)
  if (format == "html") {
    return(get_meta_for_html())
  }
}

get_meta_for_html <- function() {

  css <- system_file("rmarkdown", "template", "quarto_vignette", "resources",
                      "vignette.css", package = "quarto")
  meta <- list()
  meta$format$html <-
    list(
      `embed-resources` = TRUE,
      minimal = TRUE,
      theme = "none",
      css = css
    )
  meta
}
