# Serve Interactive Document

Serve a Shiny interactive document. By default, the document will be
rendered first and then served If you have previously rendered the
document, pass `render = FALSE` to skip rendering.

## Usage

``` r
quarto_serve(
  input,
  render = TRUE,
  port = getOption("shiny.port"),
  host = getOption("shiny.host", "127.0.0.1"),
  browse = TRUE
)
```

## Arguments

- input:

  The input file to run. Should be a file with a `server: shiny` entry
  in its YAML front-matter.

- render:

  Render the document before serving it.

- port:

  Port to listen on (defaults to 4848)

- host:

  Hostname to bind to (defaults to 127.0.0.1)

- browse:

  Open a browser to preview the content. Defaults to using the RStudio
  Viewer when running within RStudio.Pass a function (e.g.
  [`utils::browseURL`](https://rdrr.io/r/utils/browseURL.html) to
  override this behavior).
