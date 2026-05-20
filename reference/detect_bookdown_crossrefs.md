# Detect Bookdown Cross-References for Quarto Migration

Scans R Markdown or Quarto files to identify bookdown cross-references
that need to be converted to Quarto syntax. Provides detailed reports
and guidance for migrating from bookdown to Quarto.

## Usage

``` r
detect_bookdown_crossrefs(path = ".", verbose = FALSE)
```

## Arguments

- path:

  Character string. Path to a single `.Rmd` or `.qmd` file, or a
  directory containing such files. Defaults to current directory
  (`"."`).

  Typically used for Bookdown projects or R Markdown documents using
  bookdown output formats (e.g., `bookdown::pdf_document2`).

- verbose:

  Logical. If `TRUE`, shows detailed line-by-line breakdown of all
  cross-references found. If `FALSE` (default), shows compact summary by
  file.

## Value

Invisibly returns a list of detected cross-references with their file
locations, line numbers, and conversion details. Returns `NULL` if no
cross-references are found.

## Details

This function helps users migrate from bookdown to Quarto by detecting
cross-references that use bookdown syntax and need manual conversion.

### Detected Cross-Reference Types

**Auto-detectable conversions:**

- Figures: `\@ref(fig:label)`-\> `@fig-label`

- Tables: `\@ref(tab:label)` -\> `@tbl-label`

- Equations: `\@ref(eq:label)` -\> `@eq-label`

- Sections: `\@ref(label)` -\> `@sec-label`

- Theorems: `\@ref(thm:label)` -\> `@thm-label` (also lem, cor, prp,
  def, exm, exr)

**Manual conversion required:**

- Numbered equations: `(\#eq:label)` -\> requires equation restructuring

- Theorem blocks: Need explicit Quarto div syntax conversion All three
  formats from several bookdown versions are supported:

  - Old syntax with label: `{theorem, label="thm:label"}`

  - Old syntax without label: `{theorem chunk_name}`

  - New div syntax: `::: {.theorem #thm-label}`

- Section headers: Need explicit `{#sec-label}` IDs

- Figure labels: Need explicit `#| label: fig-label` in code chunks

- Table labels: Need explicit `#| label: tbl-label` in code chunks

**Unsupported in Quarto:**

- Conjecture (`cnj`) and Hypothesis (`hyp`) references

### Adaptive Guidance

The function provides **context-aware warnings** that only show syntax
patterns actually found in your files. For example, if your project only
uses the old theorem syntax without labels, you'll only see guidance for
that specific pattern, not all possible variations.

### Output Modes

**Default (`verbose = FALSE`):**

- Compact file-by-file summary

- Cross-reference counts by type

- Manual conversion requirements summary

**Verbose (`verbose = TRUE`):**

- Detailed line-by-line breakdown

- Exact bookdown -\> Quarto syntax transformations

- Context-aware conversion guidance showing only relevant syntax
  patterns

- Comprehensive examples with documentation links

## See also

**Bookdown documentation:**

- General: [Bookdown book](https://bookdown.org/yihui/bookdown/)

- [Cross-references](https://bookdown.org/yihui/bookdown/cross-references.html)

- [Figures](https://bookdown.org/yihui/bookdown/figures.html)

- [Tables](https://bookdown.org/yihui/bookdown/tables.html)

- [Equations](https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#equations)

- [Theorems](https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#theorems)

**Quarto documentation:**

- [Cross-references](https://quarto.org/docs/authoring/cross-references.html)

- [Cross-references with
  divs](https://quarto.org/docs/authoring/cross-references-divs.html)

- [Figure
  cross-references](https://quarto.org/docs/authoring/figures.html#cross-references)

- [Table
  cross-references](https://quarto.org/docs/authoring/tables.html#cross-references)

## Examples

``` r
if (FALSE) { # \dontrun{
# Scan current directory (compact output)
detect_bookdown_crossrefs()

# Scan specific file with detailed output
detect_bookdown_crossrefs("my-document.Rmd", verbose = TRUE)

# Scan directory with context-aware guidance
detect_bookdown_crossrefs("path/to/bookdown/project", verbose = TRUE)
} # }
```
