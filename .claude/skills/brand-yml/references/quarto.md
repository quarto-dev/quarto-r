# Using brand.yml with Quarto

Guide for applying brand.yml styling to Quarto documents, presentations, websites, and PDFs.

## Overview

Quarto automatically integrates `_brand.yml` to provide unified visual styling across multiple output formats including HTML, dashboards, RevealJS presentations, and Typst PDFs.

## Quick Start

Place `_brand.yml` at your project root:

```
my-project/
├── _quarto.yml
├── _brand.yml
├── index.qmd
└── ...
```

Quarto automatically discovers and applies `_brand.yml` - no configuration needed.

## Supported Formats

Brand styling automatically applies to:

- **HTML documents** - Web pages, reports
- **HTML dashboards** - Interactive dashboards
- **RevealJS presentations** - Slide decks
- **Typst PDFs** - PDF documents via Typst
- **Websites** - Multi-page Quarto websites

## Document-Level Usage

Specify brand in document frontmatter:

```yaml
---
title: "My Document"
format:
  html:
    brand: _brand.yml
---
```

Or use default discovery:

```yaml
---
title: "My Document"
format: html
---
```

If `_brand.yml` exists at project root, it's automatically applied.

## Project-Level Usage

Configure in `_quarto.yml`:

```yaml
project:
  type: website
  brand: _brand.yml

format:
  html:
    theme: default
```

## Custom Brand File Location

Specify a non-standard path:

```yaml
---
title: "My Document"
format:
  html:
    brand: branding/company-brand.yml
---
```

Or in project config:

```yaml
project:
  brand: path/to/brand.yml
```

## Light/Dark Mode

Specify color variants for light and dark modes:

```yaml
color:
  palette:
    blue: "#0066cc"
  primary:
    light: "#0066cc"
    dark: "#3399ff"
  background:
    light: "#ffffff"
    dark: "#1a1a1a"
  foreground:
    light: "#333333"
    dark: "#e0e0e0"
```

Any color in `color` or `typography` can have light/dark variants.

## Theme Layering

Control precedence with the `"brand"` keyword:

### Default (Brand Lowest Priority)

```yaml
format:
  revealjs:
    theme:
      - custom.scss
      - cosmo
```

Priority: `cosmo` > `custom.scss` > `_brand.yml`

### Brand Highest Priority

```yaml
format:
  revealjs:
    theme:
      - cosmo
      - custom.scss
      - brand
```

Priority: `_brand.yml` > `custom.scss` > `cosmo`

### Brand in Middle

```yaml
format:
  html:
    theme:
      - cosmo
      - brand
      - custom.scss
```

Priority: `custom.scss` > `_brand.yml` > `cosmo`

## Accessing Brand Data in Documents

### Shortcodes

Use shortcodes to access brand values (requires Quarto extensions):

```markdown
<!-- Access colors -->
Our primary color is {{{< brand-color primary >}}}.

<!-- Access meta information -->
Welcome to {{{< brand-meta name >}}}.
```

### SCSS Variables

Access brand colors in custom SCSS:

```scss
// Custom SCSS file
.branded-element {
  color: $brand-primary;
  background: $brand-background;
  border-color: $brand-secondary;
}
```

Brand colors are automatically available as Sass variables: `$brand-{color-name}`.

## Typst PDF Support

Brand styling works with Typst PDF output:

```yaml
---
title: "My Document"
format:
  typst:
    brand: _brand.yml
---
```

### Typst Color Variables

Access colors in Typst templates:

- `brand-color.{name}` - Palette colors (e.g., `brand-color.blue`, `brand-color.primary`)
- `brand-background-color.{name}` - Lighter background variants

### Typst Typography Support

| Element | family | weight | color | background-color | line-height |
|---------|--------|--------|-------|------------------|-------------|
| base | ✓ | ✓ | ✓ | - | ✓ |
| headings | ✓ | ✓ | ✓ | - | ✓ |
| title | ✓ | ✓ | ✓ | - | ✓ |
| monospace-inline | ✓ | ✓ | ✓ | ✓ | - |
| monospace-block | ✓ | ✓ | ✓ | ✓ | ✓ |
| link | - | ✓ | ✓ | ✓ | - |

### Typst Font Handling

Quarto automatically downloads Google Fonts and caches them for Typst. Check fonts:

```bash
quarto typst fonts --ignore-system-fonts --font-path .quarto/typst-font-cache/
```

Disable font fallback in Typst:

```typst
#set text(fallback: false)
```

## Complete Examples

### Simple HTML Document

```yaml
---
title: "Quarterly Report"
format:
  html:
    toc: true
---

# Executive Summary

Content here uses brand colors and typography automatically.
```

With `_brand.yml` at project root:

```yaml
color:
  palette:
    blue: "#0066cc"
  primary: blue
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

### RevealJS Presentation

```yaml
---
title: "Company Overview"
format:
  revealjs:
    theme:
      - default
      - brand
    logo: logo.png
---

# Introduction

Slides automatically use brand colors and fonts.
```

### Website with Brand

`_quarto.yml`:

```yaml
project:
  type: website
  brand: _brand.yml

website:
  title: "My Company"
  navbar:
    left:
      - href: index.qmd
        text: Home
      - about.qmd

format:
  html:
    theme: cosmo
    css: styles.css
```

Brand colors and typography apply across all pages.

### Dashboard

```yaml
---
title: "Sales Dashboard"
format:
  dashboard:
    brand: _brand.yml
    theme: default
---

## Row

```{python}
# Dashboard content
```
```

### Typst PDF

```yaml
---
title: "Technical Report"
format:
  typst:
    brand: _brand.yml
    margin:
      x: 2cm
      y: 2cm
---

# Overview

PDF uses brand colors and fonts via Typst.
```

## Brand Extensions

Create reusable brand packages:

```bash
quarto create extension brand
```

Structure:

```
my-brand-extension/
├── _extension.yml
├── brand.yml
├── logo.png
└── fonts/
    └── ...
```

`_extension.yml`:

```yaml
title: Company Brand
author: Your Name
version: 1.0.0
contributes:
  brand: brand.yml
```

Install extension in projects:

```bash
quarto add username/my-brand-extension
```

**Requirement**: Brand extensions need `_quarto.yml` project file.

## Sample _brand.yml for Quarto

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
    size: 1rem
    line-height: 1.6
  headings:
    family: Inter
    weight: 600
    line-height: 1.2
```

Complete example with light/dark mode:

```yaml
meta:
  name: My Company
  link: https://mycompany.com

logo:
  small: logo-icon.png
  medium:
    light: logo-dark.svg
    dark: logo-white.svg

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
  foreground:
    light: navy
    dark: "#e0e0e0"
  background:
    light: "#ffffff"
    dark: "#1a1a1a"

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
    size: 1rem
    line-height: 1.6
  headings:
    family: Inter
    weight: 600
    line-height: 1.2
  monospace:
    family: Fira Code
    size: 0.9em
  link:
    color: primary
    weight: 500
```

## Tips

- **Automatic discovery**: Place `_brand.yml` at project root for automatic application
- **Light/dark variants**: Use for websites with theme toggles
- **Layer strategically**: Use `brand` keyword to control theme precedence
- **Test across formats**: Verify brand applies correctly to HTML, PDF, and presentations
- **Extension for reuse**: Create brand extensions for multi-project consistency
- **Version control**: Include `_brand.yml` in git repository

## Troubleshooting

**Brand not applying?**
- Verify file is named `_brand.yml` (with underscore)
- Check file is at project root or specified in `brand:` field
- Ensure `_quarto.yml` exists for project-level branding
- Try explicit path in frontmatter

**Colors not matching?**
- Ensure hex colors have quotes: `"#0066cc"`
- Check color references match palette definitions
- Verify theme layering order

**Fonts not loading?**
- Verify Google Fonts spelling
- Check internet connection (required for Google Fonts)
- For Typst, check font cache: `quarto typst fonts`
- Ensure `source: google` is specified correctly

**Typst-specific issues?**
- Check font cache path: `.quarto/typst-font-cache/`
- Add `#set text(fallback: false)` to debug font issues
- Verify typography properties are supported (see table above)

**Brand extension not working?**
- Ensure `_quarto.yml` exists in project
- Verify extension is installed: `quarto list extensions`
- Check extension contributes brand: look for `contributes.brand` in `_extension.yml`
