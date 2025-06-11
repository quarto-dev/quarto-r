register_vignette_engines <- function(pkg) {
  vig_engine("html", quarto_format = "html")
  vig_engine("pdf", quarto_format = "pdf")
  vig_engine("format", quarto_format = NULL)
}


vig_engine <- function(..., quarto_format) {
  rmd_eng <- tools::vignetteEngine("rmarkdown", package = "knitr")
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
    # protect if Quarto is not installed
    if (is.null(quarto_path())) {
      msg <- c(
        "Quarto binary is required to build Quarto vignettes but is not available.",
        i = "Please make sure it is installed and found by {.code find_quarto()}."
      )
      if (is_R_CMD_check()) {
        cli::cli_inform(msg)
      } else {
        cli::cli_abort(msg, call = NULL)
      }
      return(vweave_empty(file))
    }

    # Log debug information using the new configurable logging function
    quarto_log("R_LIBS: ", Sys.getenv("R_LIBS"))
    quarto_log(".libPaths(): ", paste0(.libPaths(), collapse = ":"))
    quarto_log("Packages: ", paste0(dir(.libPaths()[1]), collapse = ","))

    quarto_render(file, ..., output_format = format, metadata = meta)
  }
}

get_meta <- function(format) {
  if (is.null(format)) {
    return(NULL)
  }
  if (format == "html") {
    return(get_meta_for_html())
  }
  if (format == "pdf") {
    return(get_meta_for_pdf())
  }
}

get_meta_for_pdf <- function() {
  meta <- list()
  meta$format$pdf <- list(
    # don't try to install CTAN package on CRAN environment
    `latex-auto-install` = !is_cran_check()
  )
  meta
}

get_meta_for_html <- function() {
  css <- system.file(
    "rmarkdown",
    "template",
    "quarto_vignette",
    "resources",
    "vignette.css",
    package = "quarto"
  )
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

is_R_CMD_check <- function() {
  !is.na(Sys.getenv("_R_CHECK_PACKAGE_NAME_", NA)) ||
    tolower(Sys.getenv("_R_CHECK_LICENSE_")) == "true"
}

# from knitr internal
is_cran_check <- function() {
  is_cran() && is_R_CMD_check()
}

is_cran <- function() {
  !rlang::is_interactive() &&
    !isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))
}

# trick from knitr to avoid problem on R CMD check (e.g. when no Quarto available)
# It will silently skip the vignette
vweave_empty <- function(file, ..., .reason = "Quarto") {
  out <- sprintf("%s.html", tools::file_path_sans_ext(basename(file)))
  writeLines(
    sprintf(
      "The vignette could not be built because %s is not available.",
      .reason
    ),
    out
  )
  out
}
