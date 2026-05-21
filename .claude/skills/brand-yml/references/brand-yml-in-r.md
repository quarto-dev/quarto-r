# Using brand.yml in R

Guide for using brand.yml in R projects beyond Shiny, including R Markdown documents, theming functions for plots and tables, and programmatic access to brand data.

## Overview

The brand.yml R package provides tools for applying brand styling to R visualizations and documents. These tools work in any R context, including R Markdown documents, Quarto, standalone scripts, and Shiny applications.

## Installation

```r
# Install brand.yml package
install.packages("brand.yml")
```

## R Markdown Integration

Use brand.yml in R Markdown documents (without `runtime: shiny`):

```yaml
---
title: "My Report"
output:
  html_document:
    theme:
      version: 5          # Required for brand.yml
      brand: true         # Auto-discover _brand.yml
---
```

Or specify a path:

```yaml
---
title: "My Report"
output:
  html_document:
    theme:
      version: 5
      brand: "path/to/brand.yml"
---
```

**Important**: Set `version: 5` to use Bootstrap 5, which has the best brand.yml support.

### Other R Markdown Formats

Brand.yml works with various R Markdown output formats:

```yaml
---
title: "Branded Report"
output:
  html_document:
    theme:
      version: 5
      brand: _brand.yml
  pdf_document: default
---
```

## Programmatic Access

Read and access brand data programmatically in any R script or document:

```r
library(brand.yml)

# Read from default location (_brand.yml in project)
brand <- read_brand_yml()

# Read from specific path
brand <- read_brand_yml("path/to/brand.yml")

# Access brand elements
brand$color$palette$blue          # "#447099"
brand$color$primary               # blue -> "#447099"
brand$typography$base$family      # "Open Sans"
brand$meta$name                   # "Company Name"

# Access all colors
brand$color$palette               # List of all palette colors
brand$color$foreground            # Foreground color
brand$color$background            # Background color
```

Use programmatically accessed brand data to:
- Display brand colors in custom visualizations
- Show brand logo with correct paths
- Apply brand fonts to custom elements
- Build branded themes dynamically
- Generate branded reports programmatically

## Branded Theming Functions

The brand.yml package includes helper functions to apply brand colors to plots and tables from popular R packages. These functions work in any R context (scripts, R Markdown, Quarto, Shiny).

### theme_brand_ggplot2()

Apply brand colors to ggplot2 visualizations:

```r
library(ggplot2)
library(brand.yml)

# Automatic brand detection
ggplot(mtcars, aes(mpg, hp)) +
  geom_point() +
  theme_brand_ggplot2()

# Explicit brand file
ggplot(mtcars, aes(mpg, hp)) +
  geom_point() +
  theme_brand_ggplot2(brand = "_brand.yml")

# Override specific colors
ggplot(mtcars, aes(mpg, hp)) +
  geom_point() +
  theme_brand_ggplot2(
    background = "white",
    foreground = "brand-gray",
    accent = "brand-blue"
  )
```

**Parameters:**
- `brand`: NULL (auto-detect), file path, brand object, or FALSE
- `background`, `foreground`, `accent`: Primary color settings
- `base_size`: Base font size (default: 11)
- Additional parameters for fine-grained control: `title_color`, `line_color`, `rect_fill`, `panel_background_fill`, `panel_grid_major_color`, etc.

### theme_brand_gt()

Apply brand colors to gt tables:

```r
library(gt)
library(brand.yml)

# Create branded table
mtcars |>
  head() |>
  gt() |>
  theme_brand_gt()

# With explicit brand
mtcars |>
  head() |>
  gt() |>
  theme_brand_gt(brand = "_brand.yml")

# Override colors
mtcars |>
  head() |>
  gt() |>
  theme_brand_gt(
    background = "white",
    foreground = "brand-gray"
  )
```

**Parameters:**
- `table`: The gt table object to theme
- `brand`: NULL (auto-detect), file path, brand object, or FALSE
- `background`: Table background color (default: `brand.color.background`)
- `foreground`: Text color (default: `brand.color.foreground`)

### theme_brand_flextable()

Apply brand colors to flextable tables:

```r
library(flextable)
library(brand.yml)

# Create branded flextable
mtcars |>
  head() |>
  flextable() |>
  theme_brand_flextable()

# With explicit brand
mtcars |>
  head() |>
  flextable() |>
  theme_brand_flextable(brand = "_brand.yml")

# Override colors
mtcars |>
  head() |>
  flextable() |>
  theme_brand_flextable(
    background = "white",
    foreground = "brand-gray"
  )
```

**Parameters:**
- `table`: The flextable object to theme
- `brand`: NULL (auto-detect), file path, brand object, or FALSE
- `background`: Table background color (default: `brand.color.background`)
- `foreground`: Text color (default: `brand.color.foreground`)

### theme_brand_plotly()

Apply brand colors to plotly visualizations:

```r
library(plotly)
library(brand.yml)

# Create branded plotly chart
plot_ly(mtcars, x = ~mpg, y = ~hp, type = "scatter", mode = "markers") |>
  theme_brand_plotly()

# With explicit brand
plot_ly(mtcars, x = ~mpg, y = ~hp, type = "scatter", mode = "markers") |>
  theme_brand_plotly(brand = "_brand.yml")

# Override colors
plot_ly(mtcars, x = ~mpg, y = ~hp, type = "scatter", mode = "markers") |>
  theme_brand_plotly(
    background = "white",
    foreground = "brand-gray",
    accent = "brand-blue"
  )
```

**Parameters:**
- `plot`: The plotly plot object to theme
- `brand`: NULL (auto-detect), file path, brand object, or FALSE
- `background`: Plot background color (default: `brand.color.background`)
- `foreground`: Text/foreground color (default: `brand.color.foreground`)
- `accent`: Accent/highlight color (default: `brand.color.primary`)

### theme_brand_thematic()

Apply brand colors to base R graphics via thematic:

```r
library(thematic)
library(brand.yml)

# Create theme object
theme <- theme_brand_thematic()

# Use with thematic_with_theme()
thematic::thematic_with_theme(theme, {
  plot(mtcars$mpg, mtcars$hp)
})

# Or use with ggplot2
thematic::thematic_with_theme(theme, {
  ggplot(mtcars, aes(mpg, hp)) +
    geom_point()
})
```

### theme_brand_thematic_on()

Immediately activate brand theming globally for base R graphics:

```r
library(thematic)
library(brand.yml)

# Turn on brand theming globally
theme_brand_thematic_on()

# Now all plots use brand colors
plot(mtcars$mpg, mtcars$hp)
hist(mtcars$mpg)

# Turn off later
thematic::thematic_off()
```

**Parameters (both functions):**
- `brand`: NULL (auto-detect), file path, brand object, or FALSE
- `background`: Background color (default: `brand.color.background`)
- `foreground`: Foreground color (default: `brand.color.foreground`)
- `accent`: Accent color (default: `brand.color.primary`)
- `...`: Additional arguments passed to thematic package

**Difference:**
- `theme_brand_thematic()`: Returns theme object for scoped use
- `theme_brand_thematic_on()`: Immediately applies theme globally

## R Markdown Example

Complete example showing theming functions in R Markdown:

````markdown
---
title: "Branded Report"
output:
  html_document:
    theme:
      version: 5
      brand: _brand.yml
---

```{r setup}
library(ggplot2)
library(gt)
library(brand.yml)
```

## Sales Analysis

```{r plot}
ggplot(mtcars, aes(mpg, hp, color = factor(cyl))) +
  geom_point(size = 3) +
  labs(title = "MPG vs Horsepower", color = "Cylinders") +
  theme_brand_ggplot2()
```

## Data Summary

```{r table}
mtcars |>
  head(10) |>
  gt() |>
  theme_brand_gt() |>
  tab_header(title = "Motor Trend Car Data")
```
````

## Quarto Integration

Works seamlessly in Quarto documents:

````markdown
---
title: "Branded Analysis"
format:
  html:
    brand: _brand.yml
---

```{r}
#| label: branded-plot
library(ggplot2)
library(brand.yml)

ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point() +
  theme_brand_ggplot2()
```
````

## Script Usage

Use in standalone R scripts:

```r
#!/usr/bin/env Rscript

library(brand.yml)
library(ggplot2)

# Read brand
brand <- read_brand_yml("_brand.yml")

# Create branded plot
p <- ggplot(mtcars, aes(mpg, hp)) +
  geom_point(color = brand$color$primary) +
  theme_brand_ggplot2()

# Save with brand colors
ggsave("output.png", p, width = 8, height = 6)
```

## Benefits

- **Consistency**: Same brand styling across all R outputs (plots, tables, documents)
- **Automatic detection**: Functions find `_brand.yml` automatically
- **Flexible override**: Easy to customize colors when needed
- **Works everywhere**: R scripts, R Markdown, Quarto, Shiny

## Tips

- **Place `_brand.yml` at project root** for automatic discovery
- **Use `read_brand_yml()`** for programmatic access to brand data
- **Combine theming functions** for cohesive branded reports
- **Set `version: 5`** in R Markdown YAML for Bootstrap 5 support
- **Test theme functions** individually before combining in documents

## Common Patterns

### Branded Report with Multiple Visualizations

```r
library(brand.yml)
library(ggplot2)
library(gt)

# Load brand
brand <- read_brand_yml()

# Create consistent visualizations
plot1 <- ggplot(data1, aes(x, y)) +
  geom_point() +
  theme_brand_ggplot2()

plot2 <- ggplot(data2, aes(x, y)) +
  geom_line() +
  theme_brand_ggplot2()

table1 <- data3 |>
  gt() |>
  theme_brand_gt()
```

### Dynamic Brand Colors

```r
library(brand.yml)

brand <- read_brand_yml()

# Use brand colors in custom visualizations
my_colors <- c(
  brand$color$primary,
  brand$color$secondary,
  brand$color$success
)

# Apply to plot
plot(data, col = my_colors[factor(group)])
```

### Conditional Branding

```r
library(brand.yml)

# Use different brands for different contexts
if (Sys.getenv("BRAND_MODE") == "internal") {
  brand <- read_brand_yml("internal-brand.yml")
} else {
  brand <- read_brand_yml("external-brand.yml")
}

# Apply to visualizations
theme <- theme_brand_ggplot2(brand = brand)
```
