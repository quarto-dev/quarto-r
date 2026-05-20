# Convert Quarto document to R script

**\[experimental\]**

Extracts R code cells from a Quarto document and writes them to an R
script file that can be rendered with the same options. The Markdown
text is not preserved, but R chunk options are kept as comment headers
using Quarto's `#|` syntax.

This function is still experimental and may slightly change in future
releases, depending on feedback.

## Usage

``` r
qmd_to_r_script(qmd, script = NULL)
```

## Arguments

- qmd:

  Character. Path to the input Quarto document (.qmd file).

- script:

  Character. Path to the output R script file. If `NULL` (default), the
  script file will have the same name as the input file but with `.R`
  extension.

## Value

Invisibly returns the path to the created R script file, or `NULL` if no
R code cells were found.

## Details

This function processes a Quarto document by:

- Extracting only R code cells (markdown and cell in other languages are
  ignored)

- Preserving chunk options as `#|` comment headers

- Adding the document's YAML metadata as a spin-style header

- Creating an R script that can be rendered with the same options

### Chunk option handling:

- Chunks with `purl: false` are completely skipped and not included in
  the output

- Chunks with `eval: false` have their code commented out (prefixed with
  `# `) in the R script

- All other chunk options are preserved as `#|` comment headers

### File handling:

- If the output R script already exists, the function will abort with an
  error

- Non-R code cells (e.g., Python, Julia, Observable JS) are ignored

- If no R code cells are found, the function does nothing and returns
  `NULL`

### Compatibility:

The resulting R script is compatible with Quarto's script rendering via
[`knitr::spin()`](https://rdrr.io/pkg/knitr/man/spin.html) and can be
rendered directly with `quarto render script.R`. See
<https://quarto.org/docs/computations/render-scripts.html#knitr> for
more details on rendering R scripts with Quarto.

The resulting R script uses Quarto's executable cell format with `#|`
comments to preserve chunk options like `label`, `echo`, `output`, etc.

The resulting R script could also be
[`source()`](https://rdrr.io/r/base/source.html)d in R, as any
`eval = FALSE` will be commented out.

### Limitations:

This function relies on static analysis of the Quarto document by
`quarto inspect`. This means that any knitr specific options like
`child=` or specific feature like
[`knitr::read_chunk()`](https://rdrr.io/pkg/knitr/man/read_chunk.html)
are not supported. They rely on tangling or knitting by knitr itself.
For this support, one should look at
[`knitr::hook_purl()`](https://rdrr.io/pkg/knitr/man/chunk_hook.html) or
[`knitr::purl()`](https://rdrr.io/pkg/knitr/man/knit.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# Convert a Quarto document to R script
qmd_to_r_script("my-document.qmd")
# Creates "my-document.R"

# Specify custom output file
qmd_to_r_script("my-document.qmd", script = "extracted-code.R")
} # }
```
