register_vignette_engines <- function(pkg) {
  vignetteEngine(
    name = "pdf",
    package = "quarto",
    pattern = "[.]qmd$",
    weave = function(file, ..., encoding = "UTF-8") {
      quarto_render(file, ..., output_format = "pdf")
    },
    tangle = vignetteEngine("knitr::rmarkdown")$tangle,
    aspell = vignetteEngine("knitr::rmarkdown")$aspell
  )
  vignetteEngine(
    name = "html",
    package = "quarto",
    pattern = "[.]qmd$",
    weave = function(file, ..., encoding = "UTF-8") {
      quarto_render(file, ..., output_format = "html")
    },
    tangle = vignetteEngine("knitr::rmarkdown")$tangle,
    aspell = vignetteEngine("knitr::rmarkdown")$aspell
  )
}
