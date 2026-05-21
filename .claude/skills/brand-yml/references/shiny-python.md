# Using brand.yml with Shiny for Python

Guide for applying brand.yml styling to Shiny for Python applications using ui.Theme.

## Overview

Shiny for Python integrates brand.yml through the `ui.Theme.from_brand()` method, which creates custom themes from `_brand.yml` files. This enables consistent branding across Shiny apps with minimal configuration.

## Installation

```bash
# Install Shiny with theme support
pip install "shiny[theme]"

# Or install separately
pip install shiny libsass

# Optional: Install brand_yml for programmatic access
pip install brand_yml
```

## Quick Start

### Automatic Discovery

Place `_brand.yml` at your app directory root:

```
my-app/
├── _brand.yml
├── app.py
└── ...
```

Then use `ui.Theme.from_brand()`:

**Shiny Express:**

```python
from shiny.express import ui

ui.page_opts(theme=ui.Theme.from_brand(__file__))

# ... rest of app
```

**Shiny Core:**

```python
from shiny import App, ui

app_ui = ui.page_fluid(
    ui.Theme.from_brand(__file__),
    ui.h2("My App"),
    # ... rest of UI
)

def server(input, output, session):
    pass

app = App(app_ui, server)
```

## ui.Theme.from_brand() Parameters

```python
ui.Theme.from_brand(brand)
```

The `brand` parameter accepts:

### File Path (Most Common)

```python
# Use __file__ for app directory
ui.Theme.from_brand(__file__)

# Explicit file path
ui.Theme.from_brand("path/to/_brand.yml")

# Explicit directory (auto-finds _brand.yml)
ui.Theme.from_brand("branding/")
```

### Brand Object

```python
from brand_yml import Brand

brand = Brand.from_yaml("_brand.yml")
ui.Theme.from_brand(brand)
```

## Search Behavior

When given `__file__` or a directory path, the method searches for `_brand.yml`:

1. In the specified directory
2. In `_brand/` subdirectory
3. In `brand/` subdirectory
4. In parent directories (recursive)

## Complete Examples

### Shiny Express App

```python
from shiny.express import input, render, ui

ui.page_opts(
    title="My Dashboard",
    theme=ui.Theme.from_brand(__file__)
)

with ui.sidebar():
    ui.input_slider("n", "Number of observations", 1, 100, 50)

@render.plot
def histogram():
    import matplotlib.pyplot as plt
    import numpy as np

    data = np.random.randn(input.n())
    plt.hist(data, bins=20)
    plt.xlabel("Value")
    plt.ylabel("Frequency")
```

### Shiny Core App

```python
from shiny import App, render, ui

app_ui = ui.page_sidebar(
    ui.sidebar(
        ui.input_slider("n", "Number of observations", 1, 100, 50),
    ),
    ui.output_plot("histogram"),
    title="My Dashboard",
    theme=ui.Theme.from_brand(__file__)
)

def server(input, output, session):
    @render.plot
    def histogram():
        import matplotlib.pyplot as plt
        import numpy as np

        data = np.random.randn(input.n())
        plt.hist(data, bins=20)
        plt.xlabel("Value")
        plt.ylabel("Frequency")

app = App(app_ui, server)
```

### With Custom Path

```python
from shiny.express import ui

# Shared brand file
ui.page_opts(theme=ui.Theme.from_brand("../shared-branding/_brand.yml"))

# Named brand file
ui.page_opts(theme=ui.Theme.from_brand("company-brand.yml"))

# Directory with _brand.yml inside
ui.page_opts(theme=ui.Theme.from_brand("branding/"))
```

### Multiple Page Types

```python
from shiny import App, ui

# page_fluid
app_ui = ui.page_fluid(
    theme=ui.Theme.from_brand(__file__),
    # ... content
)

# page_sidebar
app_ui = ui.page_sidebar(
    theme=ui.Theme.from_brand(__file__),
    ui.sidebar(
        # ... sidebar content
    ),
    # ... main content
)

# page_navbar
app_ui = ui.page_navbar(
    ui.nav_panel("Tab 1", # ...),
    ui.nav_panel("Tab 2", # ...),
    title="My App",
    theme=ui.Theme.from_brand(__file__)
)

# page_fillable
app_ui = ui.page_fillable(
    theme=ui.Theme.from_brand(__file__),
    # ... content
)
```

## Combining with Custom Theme Rules

Extend brand.yml themes with custom Sass:

```python
from shiny.express import ui

theme = (
    ui.Theme.from_brand(__file__)
    .add_rules("""
        .custom-card {
            border-radius: 0.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    """)
)

ui.page_opts(theme=theme)
```

Available theme methods (chainable):
- `.add_defaults()` - Override Bootstrap variables
- `.add_functions()` - Add Sass functions
- `.add_mixins()` - Add Sass mixins
- `.add_rules()` - Add CSS rules
- `.add_uses()` - Add Sass declarations

## Programmatic Access with brand_yml

For advanced use cases, access brand data programmatically:

```python
from brand_yml import Brand

# Read brand file
brand = Brand.from_yaml("_brand.yml")

# Or from string
yaml_content = """
color:
  palette:
    blue: "#0066cc"
  primary: blue
"""
brand = Brand.from_yaml_str(yaml_content)

# Access brand elements
brand.meta.name                    # Organization name
brand.color.palette.blue           # "#0066cc"
brand.color.primary                # "blue"
brand.typography.base.family       # Font family name

# Use in UI
from shiny import ui

app_ui = ui.page_fluid(
    theme=ui.Theme.from_brand(brand),
    ui.h2(brand.meta.name),
    # ... more content
)
```

## Sample _brand.yml for Shiny

Minimal example:

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

More complete example:

```yaml
meta:
  name: My Company
  link: https://mycompany.com

color:
  palette:
    blue: "#0066cc"
    navy: "#003366"
    gray: "#666666"
    light-gray: "#f5f5f5"
  primary: blue
  secondary: gray
  success: "#28a745"
  info: blue
  warning: "#ffc107"
  danger: "#dc3545"
  foreground: navy
  background: "#ffffff"

typography:
  fonts:
    - family: Inter
      source: google
      weight: [400, 500, 600, 700]
      style: [normal, italic]
    - family: Fira Code
      source: google
      weight: [400, 500]
  base:
    family: Inter
    size: 16px
    line-height: 1.5
  headings:
    family: Inter
    weight: 600
    line-height: 1.2
  monospace:
    family: Fira Code
    size: 14px
```

## Tips

- **Use __file__**: Most reliable way to locate `_brand.yml` in app directory
- **Start simple**: Begin with colors and one font
- **Test paths**: If brand doesn't apply, try explicit paths
- **Version control**: Include `_brand.yml` in git repository
- **Precompile for production**: Use `.to_css()` to avoid runtime Sass compilation

```python
# Development
theme = ui.Theme.from_brand(__file__)

# Production (precompile)
theme_css = ui.Theme.from_brand(__file__).to_css()
# Save to static/theme.css, then reference in production
```

## Troubleshooting

**Theme not applying?**
- Check file is named `_brand.yml` (with underscore)
- Verify `libsass` is installed: `pip install libsass`
- Try explicit path: `ui.Theme.from_brand("path/to/_brand.yml")`
- Check for YAML syntax errors

**Colors not matching?**
- Ensure hex colors have quotes: `"#0066cc"`
- Verify color names match palette definitions
- Check semantic colors reference valid palette names

**Fonts not loading?**
- Verify Google Fonts spelling and availability
- Ensure `source: google` is specified
- Check font family names match exactly
- Internet connection required for Google Fonts

**Import errors?**
- Install theme support: `pip install "shiny[theme]"`
- Or install libsass separately: `pip install libsass`

## Performance Considerations

For production apps with many instances, precompile the theme:

```python
# build_theme.py
from shiny import ui

theme = ui.Theme.from_brand("_brand.yml")
css = theme.to_css()

with open("static/brand-theme.css", "w") as f:
    f.write(css)

# Then in app.py, reference the CSS file directly
# This avoids runtime Sass compilation overhead
```
