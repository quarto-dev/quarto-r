# Quarto Preview

Render and preview a Quarto document or website project.

## Usage

``` r
quarto_preview(
  file = NULL,
  render = "auto",
  port = "auto",
  host = "127.0.0.1",
  browse = TRUE,
  watch = TRUE,
  navigate = TRUE,
  quiet = FALSE
)

quarto_preview_stop()
```

## Arguments

- file:

  The document or website project directory to preview (defaults to
  current working directory)

- render:

  For website preview, the most recent execution results of
  computational documents are used to render the site (this is to
  optimize startup time). If you want to perform a full render prior to
  serving pass "all" or a vector of specific formats to render. Pass
  "default" to render the default format for the site. For document
  preview, the document is rendered prior to preview (pass `FALSE` to
  override this).

- port:

  Port to listen on (defaults to 4848)

- host:

  Hostname to bind to (defaults to 127.0.0.1)

- browse:

  Open a browser to preview the content. Defaults to using the RStudio
  Viewer when running within RStudio.Pass a function (e.g.
  [`utils::browseURL`](https://rdrr.io/r/utils/browseURL.html) to
  override this behavior).

- watch:

  Watch for changes and automatically reload browser.

- navigate:

  Automatically navigate the preview browser to the most recently
  rendered document.

- quiet:

  Suppress warning and other messages, from R and also Quarto CLI (i.e
  `--quiet` is passed as command line)

## Value

The URL of the preview server (invisibly). This can be used to
programmatically access the server location, for example to take
screenshots with webshot2 or pass to other automation tools.

## Details

Automatically reloads the browser when input files are re-rendered or
document resources (e.g. CSS) change.

## Examples

``` r
if (FALSE) { # \dontrun{
# Preview the project in the current directory
quarto_preview()

# Preview a document
quarto_preview("document.qmd")

# Preview the project in "myproj" directory and use external browser
# (rather than RStudio Viewer)
quarto_preview("myproj", open = utils::browseURL)

# Capture the preview URL for programmatic use
preview_url <- quarto_preview("document.qmd", browse = FALSE)
cat("Preview available at:", preview_url, "\n")

# Take a screenshot of the preview using webshot2
if (require(webshot2)) {
  preview_url <- quarto_preview("document.qmd", browse = FALSE)
  webshot2::webshot(preview_url, "preview.png")
}

# Stop any running quarto preview
quarto_preview_stop()
} # }
```
