# Dynamic Metadata in Quarto Documents

## Introduction

This vignette demonstrates how to use
[`write_yaml_metadata_block()`](https://quarto-dev.github.io/quarto-r/reference/write_yaml_metadata_block.md)
to dynamically set metadata in Quarto documents based on R computations.
This functionality addresses a key limitation where Quarto metadata must
traditionally be static and defined in the document header.

**Important**: To use this function in Quarto documents, you must
include the `output: asis` chunk option (or `#| output: asis`) in your R
code chunks. Without this option, the YAML metadata will be displayed as
text instead of being processed as metadata.

## Basic Usage

Let’s start with a basic example where we set some metadata dynamically:

``` r

# Simulate some computed values
user_type <- "admin"
is_debug <- TRUE
current_version <- "2.1.0"
```

Now we can set metadata based on these computed values. Here is the R
cell used in the vignette source. **Note the `#| output: asis` chunk
option** - this is essential:

```` markdown
```{r}
#| label: metadata-block
#| output: asis
quarto::write_yaml_metadata_block(
  user_level = user_type,
  debug_mode = is_debug,
  app_version = "2.1.0",
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
)
```
````

This will generate a YAML metadata block that looks like this in the
body of your document:

``` yaml
---
user_level: admin
debug_mode: true
app_version: 2.1.0
generated_at: 2026-05-21T11:43:52+0000
---
```

Quarto will process this metadata block as an additional metadata block
to the frontmatter one. And so, it will make the metadata available for
use throughout the document.

They can be used in various ways, such as in shortcodes or conditional
content.

- Using `{{< meta key >}}` shortcodes to access metadata values:
  <https://quarto.org/docs/authoring/variables.html#meta>

- Using `when-meta` attributes to conditionally show/hide content based
  on metadata values:
  <https://quarto.org/docs/authoring/conditional.html#matching-against-metadata>.
  **The metadata values must be a boolean.**

Each metadata block will be merged with previous metadata blocks, and
existing metadata values can be overwritten by subsequent blocks.

## Example: Using Metadata with Conditional Content

Now that we’ve set the metadata, we can use it with Quarto’s conditional
content features:

**Current user level:** admin

**App version:** 2.1.0

**Debug mode:** true

> **Debug Information**
>
> This content is only visible when `debug_mode` is true. Since we set
> it to TRUE, this message should be visible.
>
> Generated at: 2026-05-21T11:43:52+0000

## Advanced Use Case: Conditional Content Based on parameters

Another powerful use case is making Quarto parameters available as
metadata for conditional content. This allows you to control document
behavior through parameters while leveraging Quarto’s conditional
content features.

Here’s an example that demonstrates creating different versions of a
sales report based on parameters:

```` markdown
---
title: "Sales Report"
format: html 
params:
  region: "North America"
  show_confidential: false
  quarter: "Q1"
---

```{r}
#| echo: false
#| output: asis
quarto::write_yaml_metadata_block(
  params = params
)
```

# {{< meta params.quarter >}} Sales Report - {{< meta params.region >}}

::: {.content-visible when-meta="params.show_confidential"}
::: {.callout-warning}
## Confidential Information
This section contains sensitive financial data and competitor analysis.

Region: {{< meta params.region >}}
Quarter: {{< meta params.quarter >}}
:::

```{r}
# Show detailed financial breakdown
cat("Detailed revenue breakdown by product line...")
cat("\nConfidential metrics and competitor analysis...")
```
:::

::: {.content-visible unless-meta="params.show_confidential"}
::: {.callout-note}
## Public Summary
This report shows general performance metrics suitable for public distribution.

Region: `{r} params$region`
Quarter: `{r} params$quarter`
:::

```{r}
# Show summary metrics only
cat("Overall performance summary for", params$region)
cat("\nPublic-facing metrics for", params$quarter)
```
:::
````

This approach is particularly useful for:

1.  **Parameterized reporting**: Generate different document versions
    based on input parameters
2.  **Conditional content**: Show or hide sections dynamically based on
    computed values
3.  **Document customization**: Tailor content and presentation for
    different contexts or audiences
4.  **Workflow automation**: Control document behavior programmatically
    through parameter passing

You can render different versions by passing parameters:

``` r

# Internal report with confidential data
quarto::quarto_render("sales-report.qmd", 
  execute_params = list(
    region = "North America", 
    show_confidential = TRUE, 
    quarter = "Q2"
  ))

# Public report without confidential data  
quarto::quarto_render("sales-report.qmd", 
  execute_params = list(
    region = "Europe", 
    show_confidential = FALSE, 
    quarter = "Q2"
  ))
```

The key insight is that `write_yaml_metadata_block(params = params)`
makes all your document parameters available as metadata. The boolean
ones can then be used with Quarto’s `when-meta` and `unless-meta`
conditional attributes for dynamic content control.

## Advanced Use Case: Email Variant Testing

One powerful application of dynamic metadata is variant emails using
Quarto’s email format. This example shows how to randomly select an
email variant and conditionally display different content based on that
selection:

This approach is particularly useful when deploying email reports
through [Posit Connect Quarto
integration](https://docs.posit.co/connect/user/quarto/), which supports
[email
customization](https://docs.posit.co/connect/user/quarto/#email-customization)
for automated report distribution.

```` markdown
---
title: test conditional emails
format: email
email-preview: true
---

Pick variant

```{r}
variant <- sample(1:3, 1)
```

```{r}
#| echo: false
#| output: asis
quarto::write_yaml_metadata_block(
  .list = setNames(
    list(TRUE), 
    nm = sprintf("is_email_variant_%d", variant)
  )
)
```

::: {.email}

This email was sent from Quarto! With conditional output for condition `{r} variant`

::: {.content-visible when-meta="is_email_variant_1"}

email body 1

```{r}
head(mtcars)
```

::: {.subject}
subject 1
:::

:::

::: {.content-visible when-meta="is_email_variant_2"}

email body 2 

```{r}
head(palmerpenguins::penguins)
```

::: {.subject}
subject 2
:::

:::

::: {.content-visible when-meta="is_email_variant_3"}

email body 3

```{r}
praise::praise()
```

::: {.subject}
subject 3
:::

:::

::: {.email-scheduled}
TRUE
:::

:::

## Logging

Case: `{r} variant`

Report run: `{r} Sys.time()`
````

This example demonstrates several advanced concepts:

1.  **Random variant selection**: Using
    [`sample()`](https://rdrr.io/r/base/sample.html) to randomly choose
    one of three email variants
2.  **Dynamic metadata generation**: Creating boolean metadata flags for
    each variant using
    [`sprintf()`](https://rdrr.io/r/base/sprintf.html) and
    [`setNames()`](https://rdrr.io/r/stats/setNames.html)
3.  **Conditional email content**: Each variant shows different content
    (different datasets, subjects) based on the selected metadata flag
4.  **Email-specific features**: Using Quarto’s email format with
    `.subject` divs and `.email-scheduled` metadata
5.  **Logging and tracking**: Recording which variant was selected for
    analysis purposes

## Technical Details

The
[`write_yaml_metadata_block()`](https://quarto-dev.github.io/quarto-r/reference/write_yaml_metadata_block.md)
function generates a YAML metadata block that can be inserted into the
document body. It accepts named arguments or a list, which are converted
to YAML format. The **yaml** R package is used for YAML serialization:
<https://github.com/vubiostat/r-yaml>

Look for the documentation of this package for more details on how YAML
is formatted and structured from R objects.

Currently, this package does write YAML with additional specific
handlers, for non-default behavior:

- `TRUE` and `FALSE` are converted to `true` and `false` in YAML,
  respectively.
