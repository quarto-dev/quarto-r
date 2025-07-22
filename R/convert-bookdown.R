#' Detect Bookdown Cross-References for Quarto Migration
#'
#' Scans R Markdown or Quarto files to identify bookdown cross-references that
#' need to be converted to Quarto syntax. Provides detailed reports and guidance
#' for migrating from bookdown to Quarto.
#'
#' @param path Character string. Path to a single `.Rmd` or `.qmd` file, or a
#'   directory containing such files. Defaults to current directory (`"."`).
#'
#'   Typically used for Bookdown projects or R Markdown documents using
#'   bookdown output formats (e.g., `bookdown::pdf_document2`).
#'
#' @param verbose Logical. If `TRUE`, shows detailed line-by-line breakdown of
#'   all cross-references found. If `FALSE` (default), shows compact summary
#'   by file.
#'
#' @return Invisibly returns a list of detected cross-references with their
#'   file locations, line numbers, and conversion details. Returns `NULL` if
#'   no cross-references are found.
#'
#' @details
#' This function helps users migrate from bookdown to Quarto by detecting
#' cross-references that use bookdown syntax and need manual conversion.
#'
#' ## Detected Cross-Reference Types
#'
#' **Auto-detectable conversions:**
#' - Figures: `\@ref(fig:label)`-> `@fig-label`
#' - Tables: `\@ref(tab:label)` -> `@tbl-label`
#' - Equations: `\@ref(eq:label)` -> `@eq-label`
#' - Sections: `\@ref(label)` -> `@sec-label`
#' - Theorems: `\@ref(thm:label)` -> `@thm-label` (also lem, cor, prp, def, exm, exr)
#'
#' **Manual conversion required:**
#' - Numbered equations: `(\#eq:label)` -> requires equation restructuring
#' - Theorem blocks: Need explicit Quarto div syntax conversion
#'   All three formats from several bookdown versions are supported:
#'   - Old syntax with label: `{theorem, label="thm:label"}`
#'   - Old syntax without label: `{theorem chunk_name}`
#'   - New div syntax: `::: {.theorem #thm-label}`
#' - Section headers: Need explicit `{#sec-label}` IDs
#' - Figure labels: Need explicit `#| label: fig-label` in code chunks
#' - Table labels: Need explicit `#| label: tbl-label` in code chunks
#'
#' **Unsupported in Quarto:**
#' - Conjecture (`cnj`) and Hypothesis (`hyp`) references
#'
#' ## Adaptive Guidance
#'
#' The function provides **context-aware warnings** that only show syntax patterns
#' actually found in your files. For example, if your project only uses the old
#' theorem syntax without labels, you'll only see guidance for that specific pattern,
#' not all possible variations.
#'
#' ## Output Modes
#'
#' **Default (`verbose = FALSE`):**
#' - Compact file-by-file summary
#' - Cross-reference counts by type
#' - Manual conversion requirements summary
#'
#' **Verbose (`verbose = TRUE`):**
#' - Detailed line-by-line breakdown
#' - Exact bookdown -> Quarto syntax transformations
#' - Context-aware conversion guidance showing only relevant syntax patterns
#' - Comprehensive examples with documentation links
#'
#' @examples
#' \dontrun{
#' # Scan current directory (compact output)
#' detect_bookdown_crossrefs()
#'
#' # Scan specific file with detailed output
#' detect_bookdown_crossrefs("my-document.Rmd", verbose = TRUE)
#'
#' # Scan directory with context-aware guidance
#' detect_bookdown_crossrefs("path/to/bookdown/project", verbose = TRUE)
#' }
#'
#' @seealso
#' **Bookdown documentation:**
#' - General: [Bookdown book](https://bookdown.org/yihui/bookdown/)
#' - [Cross-references](https://bookdown.org/yihui/bookdown/cross-references.html)
#' - [Figures](https://bookdown.org/yihui/bookdown/figures.html)
#' - [Tables](https://bookdown.org/yihui/bookdown/tables.html)
#' - [Equations](https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#equations)
#' - [Theorems](https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#theorems)
#'
#' **Quarto documentation:**
#' - [Cross-references](https://quarto.org/docs/authoring/cross-references.html)
#' - [Cross-references with divs](https://quarto.org/docs/authoring/cross-references-divs.html)
#' - [Figure cross-references](https://quarto.org/docs/authoring/figures.html#cross-references)
#' - [Table cross-references](https://quarto.org/docs/authoring/tables.html#cross-references)
#'
#' @export
detect_bookdown_crossrefs <- function(path = ".", verbose = FALSE) {
  all_results <- .scan_files(path)

  if (is.null(all_results)) {
    return(invisible(NULL))
  }

  # Determine project_path for relative file paths in reporting
  project_path <- if (fs::is_file(path)) fs::path_dir(path) else path

  .report_findings(all_results, project_path, verbose = verbose)
  .show_summary(all_results)

  # Only show detailed warnings if verbose = TRUE
  .show_warnings(all_results, original_path = path, verbose = verbose)

  invisible(all_results)
}

# Patterns for detecting bookdown cross-references
bookdown_patterns <- list(
  ## https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#equations
  numbered_equation = "\\(\\\\#eq:([^)]+)\\)",
  ## https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#theorems
  theorem_block_labeled = "```\\{%s[^}]*label=\"([^\"]+)\"[^}]*\\}", # Old bookdown syntax with label option
  theorem_block_unlabeled = "```\\{%s\\s+([^,\\s}]+)(?!.*=)[^}]*\\}", # Old bookdown syntax without label option
  theorem_div = ":::\\s*\\{\\.%s\\s+#([^\\s}]+)[^}]*\\}" # New div syntax
)

bookdown_theorem_types <- list(
  "theorem" = "thm",
  "lemma" = "lem",
  "corollary" = "cor",
  "proposition" = "prp",
  "definition" = "def",
  "example" = "exm",
  "exercise" = "exr"
)

bookdown_unsupported_types <- c(
  "conjecture" = "cnj",
  "hypothesis" = "hyp"
)

# Bookdown <-> Quarto cross-reference prefix mapping
crossref_prefix <- c(
  # same prefix in bookdown and quarto
  setNames(
    nm = c("fig", "eq", "thm", "lem", "cor", "prp", "def", "exm", "exr")
  ),
  # Special mapping for tables
  tab = "tbl",
  # No prefix in bookdown
  "sec"
)

# CLI theme
.cli_theme_crossref <- list(
  span.note = list(color = "yellow"),
  span.warning = list(color = "red"),
  span.danger = list(color = "red"),
  span.red = list(color = "red"),
  span.blue = list(color = "blue"),
  span.green = list(color = "green")
)

# Warning configurations for different conversion types
.warning_messages_by_type <- function(type) {
  switch(
    type,
    sec = list(
      alert = "Section reference detected - requires manual header updates:",
      details = c(
        "Bookdown automatically generates IDs from headers like:",
        "  {.red {.code # Hello World}} -> auto-generated ID: {.red {.code hello-world}}",
        "  referenced with {.red {.code \\@ref(hello-world)}}",
        "",
        "Quarto requires explicit header IDs:",
        "  {.green {.code # Hello World {{#sec-hello-world}}}} -> explicit ID: {.green {.code sec-hello-world }}",
        "  referenced with {.green {.code @sec-hello-world}}"
      )
    ),
    tab = list(
      alert = "Table reference detected - requires manual table labeling:",
      details = c(
        "Bookdown automatically generates table IDs from kable/knitr functions based on cell label:",
        "  {.red ```{{r mylabel}} }",
        "  {.red kable(mtcars, caption = 'My Table')}",
        "  {.red ```} -> auto-generated ID: {.red {.code tab:mylabel}}",
        "  referenced with {.red {.code \\@ref(tab:mylabel)}}",
        "",
        "Quarto requires explicit table IDs with tbl prefix in R code chunks:",
        "  {.green ```{{r}} }",
        "  {.green #| label: tbl-mylabel}",
        "  {.green #| tbl-cap: 'My Table'}",
        "  {.green kable(mtcars)}",
        "  {.green ```}",
        "  referenced with {.green {.code @tbl-mylabel}}",
        "",
        "See documentation:",
        "  Bookdown: {.url https://bookdown.org/yihui/bookdown/tables.html}",
        "  Quarto:   {.url https://quarto.org/docs/authoring/tables.html#cross-references}"
      )
    ),
    fig = list(
      alert = "Figure reference detected - requires manual figure labeling:",
      details = c(
        "Bookdown automatically generates figure IDs from code chunk labels:",
        "  {.red ```{{r mylabel, fig.cap='My Figure'}} }",
        "  {.red plot(mtcars)}",
        "  {.red ```} -> auto-generated ID: {.red {.code fig:mylabel}}",
        "  referenced with {.red {.code \\@ref(fig:mylabel)}}",
        "",
        "Quarto requires explicit figure IDs with fig prefix:",
        "  {.green ```{{r}} }",
        "  {.green #| label: fig-mylabel}",
        "  {.green #| fig-cap: 'My Figure'}",
        "  {.green plot(mtcars)}",
        "  {.green ```}",
        "  referenced with {.green {.code @fig-mylabel}}",
        "",
        "See documentation:",
        "  Bookdown: {.url https://bookdown.org/yihui/bookdown/figures.html}",
        "  Quarto:   {.url https://quarto.org/docs/authoring/figures.html#cross-references}"
      )
    ),
    numbered_equation = list(
      alert = "Numbered equation detected - requires manual restructuring:",
      details = c(
        "Bookdown numbered equations:",
        "  {.red \\begin{{equation}} }",
        "  {.red f\\left(k\\right) = \\binom{{n}}{{k}} p^k\\left(1-p\\right)^{{n-k}} }",
        "  {.red (\\#eq:binom)}",
        "  {.red \\end{{equation}} }",
        "Quarto numbered equations:",
        "  {.green $$\\bar{{X}} = \\frac{{1}}{{n}} \\sum_{{i=1}}^{{n}} X_i$$ {{#eq-mean}} }",
        "",
        "See documentation:",
        "  Bookdown: {.url https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#equations}",
        "  Quarto:   {.url https://quarto.org/docs/authoring/cross-references.html#equations}"
      )
    ),
    theorem = list(
      alert = "Theorem environments require manual restructuring",
      details = c(
        "Bookdown: {.red ```{{theorem, label=\"thm:label\"}} }",
        "Quarto:   {.green :::{{#thm-label}} }",
        "See: {.url https://quarto.org/docs/authoring/cross-references.html#theorems-and-proofs}"
      )
    ),
    unsupported = list(
      alert = "Cross-references to types not supported in Quarto",
      details = c(
        "",
        "The following bookdown cross-reference types are not supported in Quarto:",
        # {.red Conjecture (cnj) }"
        paste0(
          "* {.red ",
          tools::toTitleCase(names(bookdown_unsupported_types)),
          " (",
          bookdown_unsupported_types,
          ") }"
        ),
        "",
        "Consider these alternatives:",
        "* Convert to regular text without cross-references",
        "* Use supported theorem types (theorem, lemma, corollary, etc.)",
        "* Create custom callout blocks with manual numbering"
      )
    )
  )
}

.get_detection_message <- function(result) {
  if (result$type == "sec") {
    # Extract section_id when needed
    section_id <- gsub(
      "\\\\@ref\\(([^)]+)\\)",
      "\\1",
      result$bookdown_syntax,
      perl = TRUE
    )

    list(
      type = "info",
      message = paste0(
        "  {.note Note}: Also ensure the corresponding header has {.blue {.code {{#sec-",
        section_id,
        "}}}}"
      )
    )
  } else if (result$type == "tab") {
    # Extract table_id when needed
    table_id <- gsub(
      "\\\\@ref\\(tab:([^)]+)\\)",
      "\\1",
      result$bookdown_syntax,
      perl = TRUE
    )

    list(
      type = "info",
      message = paste0(
        "  {.note Note}: Also ensure the corresponding table has tbl prefxed id, either {.blue {.code {{#tbl-",
        table_id,
        "}}}} or {.blue {.code label=\"tbl-",
        table_id,
        "\"}} in the r cell."
      )
    )
  } else if (result$type == "fig") {
    # Extract figure_id when needed
    figure_id <- gsub(
      "\\\\@ref\\(fig:([^)]+)\\)",
      "\\1",
      result$bookdown_syntax,
      perl = TRUE
    )

    list(
      type = "info",
      message = paste0(
        "  {.note Note}: Also ensure the corresponding code chunk has {.blue {.code #| label: fig-",
        figure_id,
        "}}"
      )
    )
  } else if (result$type == "numbered_equation") {
    list(
      type = "warning",
      message = "  {.warning Requires manual conversion}: Equation structure must be changed"
    )
  } else if (grepl("_block$", result$type)) {
    list(
      type = "warning",
      message = "  {.warning Requires manual conversion}: Theorem block structure must be changed"
    )
  } else if (grepl("_unsupported$", result$type)) {
    list(
      type = "danger",
      message = "  {.danger Not supported in Quarto}: Consider {.href [custom cross-references](https://quarto.org/docs/authoring/cross-references-custom.html)} or supported theorem types."
    )
  } else {
    NULL
  }
}
# Extract matches for a pattern
.extract_pattern_matches <- function(content, pattern, perl = TRUE) {
  matches <- regmatches(content, gregexpr(pattern, content, perl = perl))
  line_numbers <- which(grepl(pattern, content, perl = perl))

  list(matches = matches, line_numbers = line_numbers)
}

# Generic pattern processor - handles both single and multiple patterns
.process_patterns <- function(content, file_path, pattern_configs) {
  results <- list()

  for (config in pattern_configs) {
    match_data <- .extract_pattern_matches(content, config$pattern)

    if (length(match_data$line_numbers) > 0) {
      for (i in seq_along(match_data$line_numbers)) {
        line_idx <- match_data$line_numbers[i]
        line_matches <- match_data$matches[[line_idx]]

        if (length(line_matches) > 0) {
          for (match in line_matches) {
            # Apply the transformation function
            result <- config$transform_fn(match, file_path, line_idx, config)
            if (!is.null(result)) {
              results[[length(results) + 1]] <- result
            }
          }
        }
      }
    }
  }

  results
}

.process_numbered_equations <- function(content, file_path) {
  .transform_numbered_equation <- function(match, file_path, line_idx, config) {
    eq_id <- gsub(config$pattern, "\\1", match, perl = TRUE)
    list(
      file = file_path,
      line = line_idx,
      bookdown_syntax = match,
      quarto_syntax = paste0("{#eq-", eq_id, "}"),
      type = "numbered_equation"
    )
  }
  configs <- list(
    list(
      pattern = bookdown_patterns$numbered_equation,
      transform_fn = .transform_numbered_equation
    )
  )
  .process_patterns(content, file_path, configs)
}

.process_theorem_blocks <- function(content, file_path) {
  # transform functions for different theorem patterns

  # Transform old syntax WITH label
  .transform_theorem_block_labeled <- function(
    match,
    file_path,
    line_idx,
    config
  ) {
    label <- gsub(config$pattern, "\\1", match, perl = TRUE)

    # Extract theorem type from config$type (e.g., "lem_block_labeled" -> "lem")
    thm_type <- gsub("_block_labeled", "", config$type)
    list(
      file = file_path,
      line = line_idx,
      bookdown_syntax = match,
      quarto_syntax = paste0(":::{#", thm_type, "-", label, "}"),
      type = config$type
    )
  }

  # Transform old syntax WITHOUT label (uses chunk name)
  .transform_theorem_block_unlabeled <- function(
    match,
    file_path,
    line_idx,
    config
  ) {
    # Extract theorem type from config$type (e.g., "theorem_block_unlabeled" -> "theorem")
    thm_type <- gsub("_block_unlabeled", "", config$type)

    # Get the Quarto prefix from config
    quarto_prefix <- bookdown_theorem_types[[thm_type]]

    # Fallback if not found
    if (is.null(quarto_prefix)) {
      quarto_prefix <- "thm"
    }

    list(
      file = file_path,
      line = line_idx,
      bookdown_syntax = match,
      quarto_syntax = paste0(
        "Manual conversion required: Use ::: {#",
        quarto_prefix,
        "-<id>} syntax. See https://quarto.org/docs/authoring/cross-references.html#theorems-and-proofs"
      ),
      type = config$type
    )
  }

  # Transform new div syntax
  .transform_theorem_div <- function(match, file_path, line_idx, config) {
    label <- gsub(config$pattern, "\\1", match, perl = TRUE)

    # Extract theorem type from config$type (e.g., "theorem_div" -> "theorem")
    thm_type <- gsub("_div", "", config$type)

    # Map to the correct Quarto prefix
    quarto_prefix <- bookdown_theorem_types[[thm_type]]
    if (is.null(quarto_prefix)) {
      quarto_prefix <- "thm" # fallback
    }

    list(
      file = file_path,
      line = line_idx,
      bookdown_syntax = match,
      quarto_syntax = paste0(":::{#", quarto_prefix, "-", label, "}"),
      type = config$type
    )
  }

  .build_config <- function(thm_pattern, transform_fn, type_suffix) {
    function(thm_type) {
      list(
        pattern = sprintf(thm_pattern, thm_type),
        transform_fn = transform_fn,
        type = paste0(thm_type, type_suffix)
      )
    }
  }

  # Create configurations for all theorem types
  config_labeled <- .build_config(
    bookdown_patterns$theorem_block_labeled,
    .transform_theorem_block_labeled,
    "_block_labeled"
  )
  config_unlabeled <- .build_config(
    bookdown_patterns$theorem_block_unlabeled,
    .transform_theorem_block_unlabeled,
    "_block_unlabeled"
  )
  config_div <- .build_config(
    bookdown_patterns$theorem_div,
    .transform_theorem_div,
    "_div"
  )

  # Concatenate all configurations in one list with all theorem types
  all_configs <- Map(
    function(thm_type) {
      list(
        config_labeled(thm_type),
        config_unlabeled(thm_type),
        config_div(thm_type)
      )
    },
    names(bookdown_theorem_types),
    USE.NAMES = FALSE
  )
  all_configs <- unlist(all_configs, recursive = FALSE)

  # Apply the processing to the content
  .process_patterns(content, file_path, all_configs)
}

.process_unsupported_crossrefs <- function(content, file_path) {
  .transform_unsupported <- function(match, file_path, line_idx, config) {
    list(
      file = file_path,
      line = line_idx,
      bookdown_syntax = match,
      quarto_syntax = "NOT SUPPORTED IN QUARTO",
      type = config$type
    )
  }
  configs <- lapply(bookdown_unsupported_types, function(unsupported_type) {
    list(
      pattern = paste0("\\\\@ref\\(", unsupported_type, ":([^)]+)\\)"),
      transform_fn = .transform_unsupported,
      type = paste0(unsupported_type, "_unsupported")
    )
  })
  .process_patterns(content, file_path, configs)
}

.process_crossref_patterns <- function(content, file_path) {
  transform <- function(match, file_path, line_idx, config) {
    quarto_version <- gsub(
      config$pattern,
      config$replacement,
      match,
      perl = TRUE
    )
    list(
      file = file_path,
      line = line_idx,
      bookdown_syntax = match,
      quarto_syntax = quarto_version,
      type = config$type
    )
  }
  crossref_prefix_patterns <- Map(
    function(bookdown_type, quarto_type) {
      list(
        pattern = if (nzchar(bookdown_type)) {
          paste0("\\\\@ref\\(", bookdown_type, ":([^)]+)\\)")
        } else {
          "\\\\@ref\\(([^:)]+)\\)"
        },
        replacement = paste0("@", quarto_type, "-\\1"),
        transform_fn = transform,
        type = if (nzchar(bookdown_type)) bookdown_type else quarto_type
      )
    },
    names(crossref_prefix),
    crossref_prefix
  )
  .process_patterns(content, file_path, crossref_prefix_patterns)
}


# Main analysis function
.analyze_file <- function(file_path) {
  content <- readLines(file_path, warn = FALSE)

  # Process all types of patterns and combine directly
  c(
    .process_numbered_equations(content, file_path),
    .process_theorem_blocks(content, file_path),
    .process_crossref_patterns(content, file_path),
    .process_unsupported_crossrefs(content, file_path)
  )
}

# Common file scanning logic
.scan_files <- function(path) {
  # Check if path is a file or directory
  if (fs::is_file(path)) {
    # Single file
    if (!grepl("\\.(qmd|Rmd)$", path, ignore.case = TRUE)) {
      cli::cli_alert_info("File must be a .qmd or .Rmd file.")
      return(NULL)
    }

    all_files <- path
    cli::cli_alert_info(
      "Scanning for bookdown cross-references in file: {.href [{fs::path_file(path)}](file://{path})}."
    )
  } else if (fs::is_dir(path)) {
    # Directory - scan for all files
    qmd_files <- fs::dir_ls(path, recurse = TRUE, glob = "*.qmd")
    rmd_files <- fs::dir_ls(path, recurse = TRUE, glob = "*.Rmd")
    all_files <- c(qmd_files, rmd_files)

    if (length(all_files) == 0) {
      cli::cli_alert_info("No .qmd or .Rmd files found in the directory.")
      return(NULL)
    }

    # Build scanning message
    msg_parts <- c()
    if (length(qmd_files) > 0) {
      msg_parts <- c(msg_parts, "{length(qmd_files)} .qmd file{?s}")
    }
    if (length(rmd_files) > 0) {
      msg_parts <- c(msg_parts, "{length(rmd_files)} .Rmd file{?s}")
    }

    msg_scan <- paste0(
      "Scanning for bookdown cross-references in ",
      paste(msg_parts, collapse = " and "),
      "..."
    )
    cli::cli_alert_info(msg_scan)
  } else {
    cli::cli_alert_danger("Path does not exist: {path}")
    return(NULL)
  }

  # Analyze all files
  all_results <- list()
  for (file in all_files) {
    file_results <- .analyze_file(file)
    all_results <- c(all_results, file_results)
  }

  if (length(all_results) == 0) {
    cli::cli_alert_success(
      "No bookdown cross-references found. No conversion needed."
    )
    return(NULL)
  }

  all_results
}

.filter_results_by_type <- function(all_results, type_pattern) {
  all_results[sapply(all_results, function(x) {
    grepl(type_pattern, x$type)
  })]
}

# Consolidated reporting function
.report_findings <- function(all_results, project_path, verbose = FALSE) {
  # Group results by file for better reporting
  files_with_results <- unique(sapply(all_results, function(x) x$file))

  cli::cli_alert_warning(
    "Found {length(all_results)} bookdown cross-reference{?s} that should be converted:"
  )
  cli::cli_text("")

  for (file_path in files_with_results) {
    file_results <- all_results[sapply(all_results, function(x) {
      x$file == file_path
    })]

    if (verbose) {
      # Detailed verbose output
      cli::cli_h2(
        "File: {.file {fs::path_rel(file_path, project_path)}}"
      )

      types <- unique(sapply(file_results, function(x) x$type))

      for (type in types) {
        type_results <- file_results[sapply(file_results, function(x) {
          x$type == type
        })]

        # Special formatting for unsupported types
        header <- if (grepl("_unsupported$", type)) {
          "{tools::toTitleCase(gsub('_unsupported', '', type))} references (NOT SUPPORTED IN QUARTO):"
        } else {
          "{tools::toTitleCase(gsub('_', ' ', type))} references:"
        }

        cli::cli_h3(header)

        for (result in type_results) {
          cli::cli_li(
            "Line {result$line} ({.file {paste0(fs::path_rel(file_path, project_path), ':', result$line)}}): {.red {.code {result$bookdown_syntax}}} -> {.green {.code {result$quarto_syntax}}}"
          )
          .display_detection_message(result)
        }
      }
    } else {
      # Show compact summary by file
      type_counts <- table(sapply(file_results, function(x) x$type))

      cli::cli_li(
        "{fs::path_rel(file_path, project_path)}: {length(file_results)} reference{?s}"
      )

      for (type in names(type_counts)) {
        cli::cli_text(
          "  - {type_counts[[type]]} {tools::toTitleCase(gsub('_', ' ', type))}"
        )
      }
    }
    cli::cli_text("")
  }
}

# Analyze what theorem syntaxes were actually detected
.analyze_theorem_syntaxes <- function(all_results) {
  theorem_results <- .filter_results_by_type(
    all_results,
    paste(names(bookdown_theorem_types), collapse = "|")
  )

  theorem_types <- sapply(theorem_results, function(x) x$type)

  list(
    labeled = any(grepl("_block_labeled$", theorem_types)),
    unlabeled = any(grepl("_block_unlabeled$", theorem_types)),
    div = any(grepl("_div$", theorem_types))
  )
}

# Generate adaptive theorem warning based on detected syntaxes
.get_adaptive_theorem_warning <- function(detected_syntaxes) {
  alert <- "Theorem environments require manual restructuring"

  syntax_messages <- function(syntax_type) {
    switch(
      syntax_type,
      labeled = "Bookdown old syntax WITH label: {.red ```{{theorem, label=\"label\"}} }",
      unlabeled = "Bookdown old syntax WITHOUT label: {.red ```{{theorem chunk_name}} }",
      div = "Bookdown new div syntax: {.red :::{{.theorem #thm-label}} }"
    )
  }

  details <- c()

  # Add detected syntax messages
  for (syntax in names(detected_syntaxes)) {
    if (detected_syntaxes[[syntax]]) {
      details <- c(details, syntax_messages(syntax))
    }
  }

  # Always show Quarto syntax
  details <- c(details, "Quarto syntax: {.green :::{{#thm-label}} }")
  details <- c(
    details,
    "See: {.url https://quarto.org/docs/authoring/cross-references.html#theorems-and-proofs}"
  )

  list(alert = alert, details = details)
}


# Show summary information
.show_summary <- function(all_results) {
  cli::cli_alert_info("Summary of conversion requirements:")

  # Count by type
  type_counts <- table(sapply(all_results, function(x) x$type))
  for (type in names(type_counts)) {
    if (grepl("_unsupported$", type)) {
      cli::cli_li(
        "{type_counts[[type]]} {tools::toTitleCase(gsub('_unsupported', '', type))} reference{?s} (NOT SUPPORTED IN QUARTO)"
      )
    } else {
      cli::cli_li(
        "{type_counts[[type]]} {tools::toTitleCase(gsub('_', ' ', type))} reference{?s}"
      )
    }
  }
}

.display_detection_message <- function(result) {
  msg_info <- .get_detection_message(result)
  if (!is.null(msg_info)) {
    # Use shared theme
    cli::cli_div(theme = .cli_theme_crossref)

    switch(
      msg_info$type,
      "info" = cli::cli_alert_info(msg_info$message),
      "warning" = cli::cli_alert_warning(msg_info$message),
      "danger" = cli::cli_alert_danger(msg_info$message)
    )

    cli::cli_end()
  }
}

.get_results_by_warning_type <- function(all_results, warning_type) {
  switch(
    warning_type,
    "sec" = .filter_results_by_type(all_results, "sec"),
    "fig" = .filter_results_by_type(all_results, "fig"),
    "tab" = .filter_results_by_type(all_results, "tab"),
    "numbered_equation" = .filter_results_by_type(
      all_results,
      "numbered_equation"
    ),
    "theorem" = .filter_results_by_type(
      all_results,
      paste(names(bookdown_theorem_types), collapse = "|")
    ),
    "unsupported" = .filter_results_by_type(all_results, "_unsupported$")
  )
}

.show_warnings <- function(all_results, original_path, verbose = TRUE) {
  warning_types <- c(
    "sec",
    "fig",
    "tab",
    "numbered_equation",
    "theorem",
    "unsupported"
  )

  warning_data <- lapply(warning_types, function(warning_type) {
    results <- .get_results_by_warning_type(all_results, warning_type)

    if (length(results) > 0) {
      # Specific handling for theorem as there are multiple syntaxes
      if (warning_type == "theorem") {
        detected_syntaxes <- .analyze_theorem_syntaxes(all_results)
        config <- .get_adaptive_theorem_warning(detected_syntaxes)
      } else {
        config <- .warning_messages_by_type(warning_type)
      }

      list(
        warning_type = warning_type,
        results = results,
        config = config,
        count = length(results)
      )
    } else {
      NULL
    }
  })

  # Filter out NULL entries (no results for that type)
  warning_data <- Filter(Negate(is.null), warning_data)

  cli::cli_div(theme = .cli_theme_crossref)
  if (verbose) {
    for (data in warning_data) {
      # Display alert
      if (data$warning_type == "unsupported") {
        cli::cli_alert_danger(data$config$alert)
      } else {
        cli::cli_alert_warning(data$config$alert)
      }

      # Display details
      for (line in data$config$details) {
        cli::cli_text(line)
      }
      cli::cli_text("")
    }
  } else {
    # Display compact summary
    cli::cli_text("")
    cli::cli_alert_info("Manual conversion requirements:")

    type_names <- list(
      "sec" = "Section headers",
      "fig" = "Figure labels",
      "tab" = "Table labels",
      "numbered_equation" = "Equation structure",
      "theorem" = "Theorem blocks",
      "unsupported" = "Unsupported types"
    )

    for (data in warning_data) {
      type_name <- type_names[[data$warning_type]]
      cli::cli_li(
        "{type_name}: {data$count} reference{?s} need manual attention"
      )
    }

    cli::cli_text("")
    cli::cli_alert_info(
      "For detailed conversion guidance, run: {.run quarto::detect_bookdown_crossrefs({.str {original_path}}, verbose = TRUE)}"
    )
  }
  cli::cli_end()
}
