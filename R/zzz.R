# Register engines to support Quarto vignettes
.onLoad <- function(lib, pkg) {
  register_vignette_engines(pkg)
}
