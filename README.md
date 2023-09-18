# <img src="man/figures/quarto.png" />

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/quarto)](https://CRAN.R-project.org/package=quarto)
<!-- badges: end -->

[Quarto](https://quarto.org) is an open-source scientific and technical publishing system built on [Pandoc](https://pandoc.org).

The **quarto** package provides an R interface to frequently used operations in the Quarto Command Line Interface (CLI). The package is not a requirement for using Quarto with R. Rather, it provides an R interface to common Quarto operations for users who prefer to work in the R console rather than a terminal, and for package authors that want to programatically interface with Quarto.

Before using the Quarto R package, you should install the Quarto CLI from <https://quarto.org/docs/get-started/>.

### Render and Preview

The following functions enable you to render and preview Quarto documents and projects:

|                                                          |                                |
|---------------------------|------------------------------------|
| [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html)        | Render a file or project       |
| [`quarto_preview()`](https://quarto-dev.github.io/quarto-r/reference/quarto_preview.html)      | Live preview a file or project |
| [`quarto_preview_stop()`](https://quarto-dev.github.io/quarto-r/reference/quarto_preview.html) | Stop live previewing           |
| [`quarto_run()`](https://quarto-dev.github.io/quarto-r/reference/quarto_run.html)              | Run interactive document       |

### Publishing

These functions enable you to publish static and interactive documents, websites, and books to [Posit Connect](https://posit.co/products/enterprise/connect/) and [shinyapps.io](https://www.shinyapps.io/):

|                                                              |                                        |
|---------------------------|------------------------------------|
| [`quarto_publish_doc()`](https://quarto-dev.github.io/quarto-r/reference/quarto_publish_doc.html)  | Publish a document or presentation     |
| [`quarto_publish_site()`](https://quarto-dev.github.io/quarto-r/reference/quarto_publish_doc.html) | Current version of Quarto              |
| [`quarto_publish_app()`](https://quarto-dev.github.io/quarto-r/reference/quarto_publish_doc.html)  | Inspect metadata for a file or project |

### Configuration

These functions enable you to inspect the Quarto installation as well as the metadata for Quarto documents and projects:

|                                                     |                                        |
|---------------------------|------------------------------------|
| [`quarto_path()`](https://quarto-dev.github.io/quarto-r/reference/quarto_path.html)       | Path to the Quarto binary              |
| [`quarto_version()`](https://quarto-dev.github.io/quarto-r/reference/quarto_version.html) | Current version of Quarto              |
| [`quarto_inspect()`](https://quarto-dev.github.io/quarto-r/reference/quarto_inspect.html) | Inspect metadata for a file or project |
