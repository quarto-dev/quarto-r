
#' Register engines to support Quarto vignettes
#' @importFrom tools vignetteEngine
#' @noRd
.onLoad <- function(libname, pkgname) { # args ignored
  ## TODO: Too much duplicated code here!
  ## TODO: What to do about the 'encoding' argument?
  tools::vignetteEngine(name = "pdf",
                 package = "quarto",
                 pattern = "[.]qmd$",
                 weave = function(file, ..., encoding = "UTF-8") {
                   quarto_render(file, ..., output_format = "pdf")
                 },
                 tangle = tools::vignetteEngine("knitr::rmarkdown")$tangle,
                 aspell = tools::vignetteEngine("knitr::rmarkdown")$aspell
                 )
  tools::vignetteEngine(name = "html",
                 package = "quarto",
                 pattern = "[.]qmd$",
                 weave = function(file, ..., encoding = "UTF-8") {
                   quarto_render(file, ..., output_format = "html")
                 },
                 tangle = tools::vignetteEngine("knitr::rmarkdown")$tangle,
                 aspell = tools::vignetteEngine("knitr::rmarkdown")$aspell
                 )
  tools::vignetteEngine(name = "all",
                 package = "quarto",
                 pattern = "[.]qmd$",
                 weave = function(file, ..., encoding = "UTF-8") {
                   quarto_render(file, ..., output_format = "all")
                 },
                 tangle = tools::vignetteEngine("knitr::rmarkdown")$tangle,
                 aspell = tools::vignetteEngine("knitr::rmarkdown")$aspell
                 )
}
