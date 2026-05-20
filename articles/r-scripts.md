# Working with R Scripts

This vignette demonstrates how to work with R scripts in Quarto
workflows using the quarto R package. The package provides two main
functions for this purpose:

- [`qmd_to_r_script()`](https://quarto-dev.github.io/quarto-r/reference/qmd_to_r_script.md) -
  Extract R code cells from Quarto documents to create R scripts
- [`add_spin_preamble()`](https://quarto-dev.github.io/quarto-r/reference/add_spin_preamble.md) -
  Add YAML metadata to R scripts for use with Quarto rendering

## Extracting R Code from Quarto Documents

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) 

The
[`qmd_to_r_script()`](https://quarto-dev.github.io/quarto-r/reference/qmd_to_r_script.md)
function allows you to extract R code cells from `.qmd` files and
convert them to `.R` scripts. This is particularly useful for:

- Creating standalone R scripts from Quarto documents
- Sharing R code without the narrative text
- Converting Quarto documents for use in environments that don’t support
  `.qmd` files

### Basic Usage

``` r
library(quarto)

# Extract R code from a Quarto document to an R script
# It will output my-analysis.R
qmd_to_r_script("my-analysis.qmd"")
```

The function preserves important metadata from your Quarto document:

- **YAML metadata** is converted to spin-style headers (`#' ---`)
- **Chunk options** are preserved using Quarto’s `#|` syntax

It also have some important limitations:

- **Only R code cells** are extracted; other languages (Python, Julia,
  etc.) are ignored

### Example: Converting a Simple Quarto Document

Let’s create a sample Quarto document to demonstrate:

    example.qmd

```` markdown
# Sample Quarto document content
---
title: "My Analysis"
author: "Data Scientist"
format: html
---

# Introduction

This is a sample analysis.

```{r}
#| label: setup
#| message: false
library(ggplot2)
library(dplyr)
```

```{r}
#| label: data-viz
#| fig-width: 8
#| fig-height: 6
mtcars |>
  ggplot(aes(x = wt, y = mpg)) +
  geom_point() +
  geom_smooth()
```
````

Now let’s extract the R code:

``` r

library(quarto)

# Extract R code to a script
r_script <- qmd_to_r_script(qmd_file)
```

Let’s see what the generated R script looks like:

    example.R

``` r

#' ---
#' title: My Analysis
#' author: Data Scientist
#' format: html
#' ---
#' 

#| label: setup
#| message: false
library(ggplot2)
library(dplyr)

#| label: data-viz
#| fig-width: 8
#| fig-height: 6
mtcars |>
  ggplot(aes(x = wt, y = mpg)) +
  geom_point() +
  geom_smooth()
```

### Working with Mixed-Language Documents

When working with documents that contain multiple languages (R, Python,
JavaScript, etc.),
[`qmd_to_r_script()`](https://quarto-dev.github.io/quarto-r/reference/qmd_to_r_script.md)
will:

1.  Extract only the R code cells
2.  Provide informative messages about non-R cells
3.  Return `NULL` if no R cells are found

    mixed.qmd

```` markdown
---
title: "Mixed Language Analysis"
format: html
---

```{r}
#| label: r-analysis
data <- mtcars
summary(data)
```

```{python}
#| label: python-analysis
import pandas as pd
df = pd.DataFrame({"x": [1, 2, 3], "y": [4, 5, 6]})
print(df.head())
```

```{ojs}
//| label: js-viz
Plot.plot({
  marks: [Plot.dot(data, {x: "x", y: "y"})]
})
```
````

The function will inform you about the non-R cells and extract only the
R code:

``` r

# Extract R code from mixed-language document
mixed_r_script <- qmd_to_r_script(mixed_qmd)
#> Extracting only R code cells from
#> '/tmp/RtmpPauDSr/quarto-r-scripts-vignette2681e66840c/mixed.qmd'.
#> → Other languages will be ignored (found python and ojs).
```

The resulting R script will contain only the R code cell:

    mixed.R

``` r

#' ---
#' title: Mixed Language Analysis
#' format: html
#' ---
#' 

#| label: r-analysis
data <- mtcars
summary(data)
```

## Adding YAML Metadata to R Scripts

The
[`add_spin_preamble()`](https://quarto-dev.github.io/quarto-r/reference/add_spin_preamble.md)
function helps you add YAML metadata to existing R scripts, making them
compatible with Quarto’s script rendering feature.

### Basic Usage

``` r

# Add a simple title to an R script
add_spin_preamble("my-script.R", title = "My Analysis")

# Add custom YAML metadata
add_spin_preamble("my-script.R", 
                  preamble = list(
                    title = "Advanced Analysis",
                    author = "Data Scientist",
                    format = "html",
                    execute = list(echo = TRUE, warning = FALSE)
                  ))
```

### Example: Preparing a Script for Quarto Rendering

    simple.R

``` r

# Load required libraries
library(ggplot2)
library(dplyr)

# Analyze mtcars data
mtcars |>
  group_by(cyl) |>
  summarise(avg_mpg = mean(mpg), .groups = "drop")

# Create visualization
ggplot(mtcars, aes(x = factor(cyl), y = mpg)) +
  geom_boxplot() +
  labs(title = "MPG by Number of Cylinders",
       x = "Cylinders", y = "Miles per Gallon")
```

Now add a YAML preamble:

``` r

# Add YAML metadata for Quarto rendering
add_spin_preamble(simple_script, 
                  title = "Car Analysis",
                  preamble = list(
                    author = "R User",
                    format = list(
                      html = list(
                        code_fold = TRUE,
                        theme = "cosmo"
                      )
                    )
                  ))
#> Added spin preamble to
#> '/tmp/RtmpPauDSr/quarto-r-scripts-vignette2681e66840c/simple.R'.
```

The updated script now has YAML metadata:

    simple.R

``` r

#' ---
#' author: R User
#' format:
#'   html:
#'     code_fold: true
#'     theme: cosmo
#' title: Car Analysis
#' ---
#' 

# Load required libraries
library(ggplot2)
library(dplyr)

# Analyze mtcars data
mtcars |>
  group_by(cyl) |>
  summarise(avg_mpg = mean(mpg), .groups = "drop")

# Create visualization
ggplot(mtcars, aes(x = factor(cyl), y = mpg)) +
  geom_boxplot() +
  labs(title = "MPG by Number of Cylinders",
       x = "Cylinders", y = "Miles per Gallon")
```

This script can now be rendered with Quarto:

``` r

# Render the R script as a Quarto document
quarto_render(simple_script)
```

## Integration with Existing Workflows

These functions work seamlessly with other quarto package functions:

``` r

# Complete workflow example
library(quarto)

# 1. Extract R code from Quarto document
extracted_script <- qmd_to_r_script("analysis.qmd", output = "analysis.R")

# 2. Add additional metadata if needed
add_spin_preamble(extracted_script, 
                  title = "Extracted Analysis",
                  preamble = list(format = "pdf"))

# 3. Render the script
quarto_render(extracted_script)

# 4. Preview the output
quarto_preview(extracted_script)
```

## Summary

The
[`qmd_to_r_script()`](https://quarto-dev.github.io/quarto-r/reference/qmd_to_r_script.md)
and
[`add_spin_preamble()`](https://quarto-dev.github.io/quarto-r/reference/add_spin_preamble.md)
functions provide a powerful toolkit for working with R scripts in
Quarto workflows. Whether you’re extracting code from existing documents
or preparing scripts for Quarto rendering, these functions help bridge
the gap between narrative documents and standalone scripts.

For more advanced usage and additional options, see the function
documentation with
[`?qmd_to_r_script`](https://quarto-dev.github.io/quarto-r/reference/qmd_to_r_script.md)
and
[`?add_spin_preamble`](https://quarto-dev.github.io/quarto-r/reference/add_spin_preamble.md).
