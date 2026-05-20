# Using brand.yml with Shiny for R

Guide for applying brand.yml styling to Shiny applications using the bslib package.

## Overview

The bslib package integrates brand.yml to provide unified visual theming across Shiny applications. Define colors, fonts, and logos once in `_brand.yml`, and bslib automatically applies them to your Shiny app UI.

## Installation

```r
# Install bslib (includes brand.yml support)
install.packages("bslib")

# Optional: Install brand.yml package for theming plots/tables
install.packages("brand.yml")
```

## Quick Start

### Automatic Discovery

Place `_brand.yml` at your app directory root:

```
my-app/
├── _brand.yml
├── app.R
└── ...
```

Then use `bs_theme()` in your app:

```r
library(shiny)
library(bslib)

ui <- page_fluid(
  theme = bs_theme(),  # Automatically finds _brand.yml
  titlePanel("My App"),
  # ... rest of UI
)

server <- function(input, output, session) {
  # ...
}

shinyApp(ui, server)
```

### Search Paths

bslib automatically searches for `_brand.yml` in this order:

1. Current app directory
2. `_brand/` subdirectory
3. `brand/` subdirectory
4. Parent directories (recursive)

## bs_theme() Brand Parameter

The `brand` parameter controls how branding is applied:

### Automatic (Default)

```r
theme = bs_theme()
```

Searches for `_brand.yml` and applies it if found. No error if file doesn't exist.

### Required Brand

```r
theme = bs_theme(brand = TRUE)
```

Requires `_brand.yml` to exist. Throws error if not found.

### Explicit Path

```r
theme = bs_theme(brand = "path/to/my-brand.yml")
```

Uses specific brand file. Path can be:
- Relative to app directory: `"branding/company-brand.yml"`
- Absolute: `"/Users/name/brands/company.yml"`
- Directory (auto-finds `_brand.yml`): `"branding/"`

### Inline Brand Definition

```r
theme = bs_theme(
  brand = list(
    color = list(
      palette = list(
        blue = "#0066cc",
        gray = "#666666"
      ),
      primary = "blue",
      foreground = "gray"
    ),
    typography = list(
      fonts = list(
        list(family = "Inter", source = "google", weight = c(400, 600))
      ),
      base = "Inter"
    )
  )
)
```

### Disable Branding

```r
theme = bs_theme(brand = FALSE)
```

Ignores `_brand.yml` even if it exists.

## Using with page_*() Functions

All bslib page functions support automatic brand discovery:

```r
# page_fluid
ui <- page_fluid(
  theme = bs_theme(),
  # ... content
)

# page_sidebar
ui <- page_sidebar(
  theme = bs_theme(),
  sidebar = sidebar(
    # ... sidebar content
  ),
  # ... main content
)

# page_navbar
ui <- page_navbar(
  theme = bs_theme(),
  nav_panel("Tab 1", # ...),
  nav_panel("Tab 2", # ...)
)

# page_fillable
ui <- page_fillable(
  theme = bs_theme(),
  # ... content
)
```

## Branded Plots and Tables in Shiny

Use theming functions from the brand.yml package to style plots and tables within Shiny apps. See `brand-yml-in-r.md` for complete documentation of theming functions.

### Basic Example

```r
library(shiny)
library(bslib)
library(ggplot2)
library(gt)
library(brand.yml)

ui <- page_sidebar(
  theme = bs_theme(brand = TRUE),

  sidebar = sidebar(
    selectInput("dataset", "Dataset:", c("mtcars", "iris"))
  ),

  card(
    card_header("Branded Plot"),
    plotOutput("plot")
  ),
  card(
    card_header("Branded Table"),
    gt_output("table")
  )
)

server <- function(input, output, session) {
  output$plot <- renderPlot({
    ggplot(mtcars, aes(mpg, hp)) +
      geom_point() +
      theme_brand_ggplot2()
  })

  output$table <- render_gt({
    head(mtcars) |>
      gt() |>
      theme_brand_gt()
  })
}

shinyApp(ui, server)
```

**Benefits:**
- Consistent styling across UI, plots, and tables
- Automatic brand detection from `_brand.yml`
- Works with ggplot2, gt, flextable, plotly, and base R graphics

For detailed theming function documentation, see `brand-yml-in-r.md`.

## Complete Shiny Example

```r
library(shiny)
library(bslib)

ui <- page_sidebar(
  theme = bs_theme(brand = TRUE),  # Require _brand.yml

  sidebar = sidebar(
    title = "Controls",
    selectInput("dataset", "Dataset:",
                choices = c("iris", "mtcars")),
    numericInput("n", "Number of rows:", 10, min = 1, max = 50)
  ),

  card(
    card_header("Data Summary"),
    tableOutput("summary")
  ),

  card(
    card_header("Data Details"),
    verbatimTextOutput("details")
  )
)

server <- function(input, output, session) {
  dataset <- reactive({
    get(input$dataset)
  })

  output$summary <- renderTable({
    head(dataset(), input$n)
  })

  output$details <- renderPrint({
    summary(dataset())
  })
}

shinyApp(ui, server)
```

With `_brand.yml`:

```yaml
color:
  palette:
    brand-blue: "#0066cc"
    brand-gray: "#666666"
  primary: brand-blue
  foreground: brand-gray
  background: "#ffffff"

typography:
  fonts:
    - family: Inter
      source: google
      weight: [400, 600]
  base:
    family: Inter
    size: 16px
  headings:
    family: Inter
    weight: 600
```

## R Markdown Shiny Documents

Use brand.yml in R Markdown documents with Shiny runtime:

```yaml
---
title: "Interactive Dashboard"
output:
  html_document:
    theme:
      version: 5          # Required for brand.yml
      brand: true         # Auto-discover _brand.yml
runtime: shiny
---
```

Or specify a path:

```yaml
---
title: "Interactive Dashboard"
output:
  html_document:
    theme:
      version: 5
      brand: "path/to/brand.yml"
runtime: shiny
---
```

**Important**: Set `version: 5` to use Bootstrap 5, which has the best brand.yml support.

**Note**: For R Markdown documents without `runtime: shiny`, see `brand-yml-in-r.md`.

## Programmatic Brand Access

For advanced use cases, access brand data programmatically within Shiny:

```r
library(brand.yml)

server <- function(input, output, session) {
  # Read brand data
  brand <- read_brand_yml()

  # Use in custom UI elements
  output$brand_info <- renderUI({
    div(
      style = paste0("color: ", brand$color$primary, ";"),
      h3(brand$meta$name),
      p("Welcome to our branded app!")
    )
  })

  # Use in plots with custom styling
  output$custom_plot <- renderPlot({
    plot(mtcars$mpg, mtcars$hp,
         col = brand$color$primary,
         pch = 19)
  })
}
```

For complete documentation on programmatic access and theming functions, see `brand-yml-in-r.md`.

## Tips

- **Start simple**: Begin with colors and one font family
- **Test automatically**: Automatic discovery works well for most cases
- **Use explicit paths**: For shared brand files across multiple apps
- **Version control**: Include `_brand.yml` in your git repository
- **Validate early**: Use `brand = TRUE` during development to catch missing files
- **Combine with theming functions**: Style plots and tables consistently (see `brand-yml-in-r.md`)

## Troubleshooting

**Brand not applying to Shiny UI?**
- Check file is named `_brand.yml` (with underscore)
- Verify file is in app directory or parent directories
- Try explicit path: `bs_theme(brand = "path/to/_brand.yml")`
- Check for YAML syntax errors

**Colors not matching?**
- Verify hex colors have quotes: `"#0066cc"`
- Check color names match palette definitions
- Ensure primary/secondary colors reference valid palette names

**Fonts not loading?**
- Verify Google Fonts spelling and availability
- Check `source: google` is specified correctly
- Ensure font family names match exactly in typography elements

**Plots/tables not branded?**
- Ensure brand.yml package is installed: `install.packages("brand.yml")`
- Use theming functions: `theme_brand_ggplot2()`, `theme_brand_gt()`, etc.
- See `brand-yml-in-r.md` for complete theming documentation

## Related Documentation

- **[brand-yml-in-r.md](brand-yml-in-r.md)**: General R usage, R Markdown integration, theming functions, and programmatic access
- **[brand-yml-spec.md](brand-yml-spec.md)**: Complete brand.yml file specification
