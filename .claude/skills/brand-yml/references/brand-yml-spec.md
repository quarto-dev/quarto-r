# brand.yml Specification

Complete specification for creating valid `_brand.yml` files for the brand.yml project.

## File Naming Convention

- **Conventional name**: `_brand.yml` (auto-discovered by Shiny and Quarto)
- **Custom names**: Any `.yml` file (e.g., `my-brand.yml`) requires explicit paths
- **Location**: Typically at project root or in `_brand/` or `brand/` subdirectories

## File Structure

All fields are **optional**. Only include fields directly relevant to the brand.

```yaml
meta:           # Company/project identity information
logo:           # Logo files and variants
color:          # Color palette and semantic colors
typography:     # Fonts and text styling
defaults:       # Framework-specific customizations
```

## Meta Section

Company or project metadata.

### Simple Format

```yaml
meta:
  name: Acme
  link: https://acmecorp.com
```

### Extended Format

```yaml
meta:
  name:
    short: Acme
    full: Acme Corporation International
  link:
    home: https://www.acmecorp.com
    docs: https://docs.acmecorp.com
    github: https://github.com/acmecorp
    bluesky: https://bsky.app/profile/acmecorp.bsky.social
    mastodon: https://mastodon.social/@acmecorp
    linkedin: https://www.linkedin.com/company/acmecorp
    facebook: https://www.facebook.com/acmecorp
    twitter: https://twitter.com/acmecorp
```

**Requirements:**
- All links must include `https://` prefix
- Additional custom fields are allowed

## Logo Section

Logo files for different contexts and sizes.

### Structure

```yaml
logo:
  images:           # Named logo resources (optional)
    name: path      # Map names to file paths or URLs
  small: path       # Icon-sized logo (favicons, mobile)
  medium: path      # Standard logo (headers, navigation)
  large: path       # Large logo (hero, title slides)
```

### File Paths

- **Local files**: Relative paths from `_brand.yml` location (e.g., `logos/logo.png`)
- **Remote files**: Full URLs with `http://` or `https://`

### Light/Dark Variants

```yaml
logo:
  medium:
    light: logo-dark.png      # For light backgrounds
    dark: logo-white.png      # For dark backgrounds
```

### With Alt Text

```yaml
logo:
  images:
    header:
      path: logos/header.svg
      alt: Company logo
  medium: header
```

### Complete Example

```yaml
logo:
  images:
    header: logos/header-logo.png
    header-white: logos/header-logo-white.png
    icon: logos/icon.png
    full:
      path: logos/full-logo.svg
      alt: Acme Corporation logo
  small: icon
  medium:
    light: header
    dark: header-white
  large: full
```

## Color Section

Brand color palette and semantic color assignments.

### Structure

```yaml
color:
  palette:        # Named brand colors
    name: "#hex"  # Flat list of color names and hex values
  # Semantic theme colors (all optional)
  foreground: "#color"    # Main text color
  background: "#color"    # Main background color
  primary: "#color"       # Links, buttons, primary actions
  secondary: "#color"     # Lighter text, disabled states
  tertiary: "#color"      # Hover states, accents
  success: "#color"       # Positive actions
  info: "#color"          # Neutral information
  warning: "#color"       # Cautions
  danger: "#color"        # Errors, negative actions
  light: "#color"         # High contrast on dark
  dark: "#color"          # High contrast on light
```

### Color Palette Best Practices

- Use hex color values: `"#447099"`
- Use descriptive names following Sass conventions: `blue`, `brand-orange`, `success-green`
- Create aliases by referencing other palette colors: `purple: burgundy`
- Include Bootstrap color names when possible: `blue`, `indigo`, `purple`, `pink`, `red`, `orange`, `yellow`, `green`, `teal`, `cyan`, `white`, `black`
- When brands define ranges of shades, choose the midpoint as the primary color

### Referencing Colors

Theme colors can reference palette names:

```yaml
color:
  palette:
    brand-blue: "#447099"
    brand-orange: "#EE6331"
  primary: brand-blue      # References palette
  warning: brand-orange    # References palette
```

### Complete Example

```yaml
color:
  palette:
    white: "#FFFFFF"
    black: "#151515"
    blue: "#447099"
    orange: "#EE6331"
    green: "#72994E"
    teal: "#419599"
    burgundy: "#9A4665"
  foreground: black
  background: white
  primary: blue
  success: green
  info: teal
  warning: orange
  danger: burgundy
```

## Typography Section

Font definitions and text element styling.

### Structure

```yaml
typography:
  fonts:              # Font definitions
    - family: Name
      source: type    # file, google, bunny, or system
      # Additional source-specific fields
  base:               # Body text (optional)
  headings:           # Heading text (optional)
  monospace:          # Code text (optional)
  monospace-inline:   # Inline code (optional)
  monospace-block:    # Code blocks (optional)
  link:               # Hyperlinks (optional)
```

### Font Sources

#### Local/Remote Files

```yaml
fonts:
  - family: Open Sans
    source: file
    files:
      - path: fonts/OpenSans-Regular.ttf
        weight: 400
        style: normal
      - path: fonts/OpenSans-Bold.ttf
        weight: 700
        style: normal
      - path: https://example.com/fonts/OpenSans-Italic.ttf
        weight: 400
        style: italic
```

Proprietary fonts, should be downloaded and stored adjacent to the brand.yml file and referenced via relative paths in the `path` field.

#### Google Fonts

```yaml
fonts:
  - family: Roboto
    source: google
    weight: [400, 700]        # Optional: specific weights
    style: [normal, italic]   # Optional: specific styles
    display: block            # Optional: font-display property
```

Weight options:
- Array of numbers: `[400, 700]`
- Range (variable fonts): `400..900`
- Named weights: `[thin, normal, bold]`

#### Bunny Fonts (GDPR-compliant alternative)

```yaml
fonts:
  - family: Inter
    source: bunny
    weight: [400, 600]
    style: [normal, italic]
```

Same syntax as Google Fonts.

### Typographic Elements

All elements support these fields:
- `family`: Font family name (must match a defined font)
- `weight`: `100`-`900` or `thin`, `normal`, `bold`, etc.
- `style`: `normal` or `italic`
- `size`: CSS units (`16px`, `1rem`, `0.9em`)
- `line-height`: Number or CSS unit
- `color`: Hex value or reference to color name
- `background-color`: Hex value or reference to color name

#### Simple Format (String)

```yaml
typography:
  base: Open Sans
  headings: Roboto
  monospace: Fira Code
```

#### Extended Format (Object)

```yaml
typography:
  base:
    family: Open Sans
    weight: 400
    size: 16px
    line-height: 1.5
  headings:
    family: Roboto
    weight: 600
    style: normal
    line-height: 1.2
    color: "#333333"
  monospace:
    family: Fira Code
    weight: 400
    size: 0.9em
  monospace-inline:
    color: "#7d12ba"
    background-color: "#f8f9fa"
  monospace-block:
    color: foreground
    background-color: background
    line-height: 1.4
  link:
    weight: 600
    color: primary
    decoration: underline
```

**Note**: Base text color uses `color.foreground` by default. Do not specify color in base unless overriding.

### Complete Example

```yaml
typography:
  fonts:
    - family: Open Sans
      source: google
      weight: [400, 600, 700]
      style: [normal, italic]
    - family: Roboto Slab
      source: google
      weight: [600, 900]
    - family: Fira Code
      source: bunny
      weight: [400, 500]
  base:
    family: Open Sans
    size: 16px
    line-height: 1.5
  headings:
    family: Roboto Slab
    weight: 600
  monospace: Fira Code
  link:
    color: primary
    weight: 600
```

## Defaults Section

Framework-specific customizations. Use sparingly - only when brand requirements cannot be met through the standard sections above.

### Structure

```yaml
defaults:
  bootstrap:      # Bootstrap/bslib customizations
    functions:    # SCSS function declarations (string)
    defaults:     # Bootstrap variable overrides (mapping)
    mixins:       # SCSS mixins (string)
    rules:        # Additional SCSS rules (string)
  quarto:         # Quarto-specific settings
    format:       # Format-specific options
  shiny:          # Shiny-specific settings
    theme:
      defaults:   # Bootstrap variables
      rules:      # Additional SCSS rules
```

### Example

```yaml
defaults:
  bootstrap:
    defaults:
      navbar-bg: $brand-orange
    rules: |
      .btn-primary {
        border-radius: 0.5rem;
      }
  shiny:
    theme:
      defaults:
        navbar-padding-y: 1rem
```

**Note**: Colors from `color.palette` are available as Sass variables: `$brand-{color_name}`

## Validation Rules

When creating `_brand.yml` files:

1. **All fields are optional** - only include what's needed
2. **Prefer hex colors** - use `"#447099"` format
3. **Prefer simple syntax** - use strings instead of objects when possible
4. **Follow Sass naming** - color/font names use lowercase and hyphens
5. **Include URLs with protocol** - always use `https://`
6. **Reference before use** - define colors/fonts before referencing them
7. **Keep it concise** - simpler is better

## Complete Minimal Example

```yaml
color:
  palette:
    blue: "#0066cc"
    gray: "#666666"
  primary: blue
  foreground: gray
  background: "#ffffff"

typography:
  fonts:
    - family: Inter
      source: google
      weight: [400, 600]
  base: Inter
  headings:
    weight: 600
```

## Complete Comprehensive Example

See the example in the document provided to you (brand-yml.prompt.txt) for a full-featured _brand.yml with all options demonstrated.
