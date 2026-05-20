# quarto

[Quarto](https://quarto.org) is an open-source scientific and technical
publishing system built on [Pandoc](https://pandoc.org).

The **quarto** package provides an R interface to frequently used
operations in the Quarto Command Line Interface (CLI). The package is
not a requirement for using Quarto with R. Rather, it provides an R
interface to common Quarto operations for users who prefer to work in
the R console rather than a terminal, and for package authors that want
to interface with Quarto using scripts.

Before using the Quarto R package, you should install the Quarto CLI
from <https://quarto.org/docs/get-started/>.

## Installing the package

Latest released version from CRAN

``` r

# latest release version 
install.packages("quarto")
```

Latest dev version from Github

``` r

# dev version
pak::pak("quarto-dev/quarto-r")
# or
remotes::install_github("quarto-dev/quarto-r")
```

or Latest build of dev version from r-universe

``` r

install.packages('quarto', repos = c('https://quarto-dev.r-universe.dev', 'https://cloud.r-project.org'))
```

Look at the [Functions Reference
page](https://quarto-dev.github.io/quarto-r/reference/index.html) to see
the list of functions available in the package.
