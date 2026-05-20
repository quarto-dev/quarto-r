# Publish Quarto Documents

Publish Quarto documents to Posit Connect, ShinyApps, and RPubs

## Usage

``` r
quarto_publish_doc(
  input,
  name = NULL,
  title = NULL,
  server = NULL,
  account = NULL,
  render = c("local", "server", "none"),
  metadata = list(),
  ...
)

quarto_publish_app(
  input = getwd(),
  name = NULL,
  title = NULL,
  server = NULL,
  account = NULL,
  render = c("local", "server", "none"),
  metadata = list(),
  ...
)

quarto_publish_site(
  input = getwd(),
  name = NULL,
  title = NULL,
  server = NULL,
  account = NULL,
  render = c("local", "server", "none"),
  metadata = list(),
  ...
)
```

## Arguments

- input:

  The input file or project directory to be published. Defaults to the
  current working directory.

- name:

  Name for publishing (names must be unique within an account). Defaults
  to the name of the `input`.

- title:

  Free-form descriptive title of application. Optional; if supplied,
  will often be displayed in favor of the name. When deploying a new
  document, you may supply only the title to receive an auto-generated
  name

- account, server:

  Uniquely identify a remote server with either your user `account`, the
  `server` name, or both. If neither are supplied, and there are
  multiple options, you'll be prompted to pick one.

  Use
  [`accounts()`](https://rstudio.github.io/rsconnect/reference/accounts.html)
  to see the full list of available options.

- render:

  `local` to render locally before publishing; `server` to render on the
  server; `none` to use whatever rendered content currently exists
  locally. (defaults to `local`)

- metadata:

  Additional metadata fields to save with the deployment record. These
  fields will be returned on subsequent calls to
  [`deployments()`](https://rstudio.github.io/rsconnect/reference/deployments.html).

  Multi-value fields are recorded as comma-separated values and returned
  in that form. Custom value serialization is the responsibility of the
  caller.

- ...:

  Named parameters to pass along to
  [`rsconnect::deployApp()`](https://rstudio.github.io/rsconnect/reference/deployApp.html)

## Examples

``` r
if (FALSE) { # \dontrun{
library(quarto)
quarto_publish_doc("mydoc.qmd")
quarto_publish_app(server = "shinyapps.io")
quarto_publish_site(server = "rstudioconnect.example.com")
} # }
```
