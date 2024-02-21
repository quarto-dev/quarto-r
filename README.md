# quarto <a href="https://quarto-dev.github.io/quarto-r/"><img src="man/figures/logo.png" align="right" height="138" alt="quarto website" /></a>

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/quarto)](https://CRAN.R-project.org/package=quarto)
[![R-CMD-check](https://github.com/quarto-dev/quarto-r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/quarto-dev/quarto-r/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/quarto-dev/quarto-r/branch/main/graph/badge.svg)](https://app.codecov.io/gh/quarto-dev/quarto-r?branch=main)
<!-- badges: end -->

[Quarto](https://quarto.org) is an open-source scientific and technical publishing system built on [Pandoc](https://pandoc.org).

The **quarto** package provides an R interface to frequently used operations in the Quarto Command Line Interface (CLI). The package is not a requirement for using Quarto with R. Rather, it provides an R interface to common Quarto operations for users who prefer to work in the R console rather than a terminal, and for package authors that want to interface with Quarto using scripts.

Before using the Quarto R package, you should install the Quarto CLI from <https://quarto.org/docs/get-started/>.

## Installing the package 

Latest released version from CRAN

```r
# latest release version 
install.packages("quarto")
```

Latest dev version from Github 
```r
# dev version
pak::pak("quarto-dev/quarto-r")
# or
remotes::install_github("quarto-dev/quarto-r")
```

or Latest build of dev version from r-universe 
```r
install.packages('quarto', repos = c('https://quarto-dev.r-universe.dev', 'https://cloud.r-project.org'))
```

Look at the [Functions Reference page](https://quarto-dev.github.io/quarto-r/reference/index.html) to see the list of functions available in the package.
