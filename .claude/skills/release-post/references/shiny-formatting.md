# Shiny Blog Formatting Conventions

Shiny-specific formatting requirements for blog posts on shiny.posit.co. These conventions are for the Quarto-based Shiny blog.

## Frontmatter Format

Shiny blog posts use Quarto YAML frontmatter with this structure:

```yaml
---
title: Package Name Version
description: &desc |
  Brief description of the package and release.
author: "Author Name"
date: "YYYY-MM-DD"

image: &img feature.png

open-graph:
  image: *img
  description: *desc
twitter-card:
  image: *img
  description: *desc
---
```

### Required Fields

- **`title`**: Display title (no specific format required, flexible)
  - Can be: `"packagename version"`, `"Package Name x.y.z"`, or descriptive
  - Examples:
    - `"shinyswatch 0.7.0"`
    - `"Reintroducing the Shiny Extension for VS Code"`
    - `"Branded theming for Shiny for Python apps"`
- **`description`**: Brief summary with YAML anchor for reuse
  - Use `&desc` anchor and `|` for multi-line
  - Reuse in social media cards with `*desc`
- **`author`**: Author name in quotes (can be single string or array)
  - Single: `"Garrick Aden-Buie"`
  - Multiple: `["Author One", "Author Two"]`
- **`date`**: ISO format in quotes `"YYYY-MM-DD"`
- **`image`**: Path to featured image (relative to post directory)

### Social Media Cards

Use YAML anchors to avoid repeating the description:

```yaml
description: &desc |
  Your description here that will be reused.

open-graph:
  description: *desc
twitter-card:
  description: *desc
```

The `&desc` creates an anchor, and `*desc` references it.

### Optional But Common Fields

- **`filters`**: Quarto filters to use
  - `shinylive` - For embedding Shinylive apps
  - `line-highlight` - For highlighting specific lines
- **`engine`**: Quarto engine (`knitr`, `markdown`, `jupyter`)
- **`freeze`**: Set to `true` if the post includes *any* computational output
- **`format`**: HTML format options
  - `code-link: true` - Enable code linking
  - `anchor-sections: true` - Enable section anchors
  - `reference-location: document` or `section` - Where to place footnotes
- **`code-annotations`**: Set to `hover` for hover annotations
- **`editor`**: Editor options like `render-on-save: true`

### Image Options

Additional image control fields:

```yaml
image: feature.svg
imagealt: "Alternative text for image"
image-header-disable: true  # Don't show image in header
```

### What's NOT Included

Unlike Tidyverse posts, Shiny posts do **not** include:

- `output: hugodown::hugo_document`
- `slug` (filename determines URL)
- `photo.url` and `photo.author` (different image structure)
- Consistent `categories` field (optional, varies by post)

## Title Format

The main title can be flexible:

```markdown
# packagename version
```

Or more descriptive:

```markdown
# Reintroducing the Shiny Extension for VS Code
```

There's less rigid formatting for titles in Shiny posts.

## Lead Paragraphs

Shiny posts may use a lead paragraph div for emphasis:

```markdown
::: lead
**We're excited to announce the new Shiny extension for VS Code!**
:::
```

This creates a larger, emphasized opening paragraph.

## Code Formatting

### For Python Packages

Use bash code blocks for installation:

````markdown
```bash
pip install packagename
```
````

With extras:

````markdown
```bash
pip install "packagename[extra]"
```
````

### For R Packages

Use R code blocks:

````markdown
```r
install.packages("packagename")
```
````

For multiple packages:

````markdown
```r
install.packages(c("shiny", "bslib"))
```
````

### Code Block Attributes

Shiny posts use Quarto code block attributes:

````markdown
```{.python filename="app.py"}
from shiny import App

# code here
```
````

````markdown
```{r install-bslib}
#| eval: false
install.packages("bslib")
```
````

### Line Highlighting

Use `# <<` comments to highlight lines (requires `line-highlight` filter):

````markdown
```{.python filename="app.py"}
from shiny.express import ui
import shinyswatch

ui.page_opts(theme=shinyswatch.theme.darkly)  # <<

# rest of code...
```
````

### Code Annotations

With `code-annotations: hover` in frontmatter, you can add annotations:

```python
result = some_function()  # <1>
```

```markdown
1. This annotation explains the line above
```

## Tabsets for Multiple Variants

Shiny posts frequently use tabsets to show Express vs Core mode or Python vs R:

````markdown
::: {.panel-tabset .shiny-mode-tabset group="shiny-app-mode"}
#### Express

```{.python filename="app.py"}
from shiny.express import ui
# Express code
```

#### Core

```{.python filename="app.py"}
from shiny import ui
# Core code
```
:::
````

### Nested Tabsets

You can nest tabsets for Before/After within Express/Core:

````markdown
::: {.panel-tabset group="shiny-app-mode"}
#### Express

::: {.panel-tabset}
##### Before

```python
# old code
```

##### After

```python
# new code
```
:::

#### Core

::: {.panel-tabset}
##### Before

```python
# old code
```

##### After

```python
# new code
```
:::
:::
````

## Callouts

Quarto callouts for notes, tips, warnings:

```markdown
::: {.callout-tip title="Writing brand.yml with the help of an LLM"}
We know that writing YAML isn't everyone's cup of tea!
...
:::
```

Types: `note`, `tip`, `warning`, `caution`, `important`

## Embedded Media

### Videos

````markdown
::: column-page
```{=html}
<video controls>
  <source src="videos/demo.webm" type="video/webm">
  <source src="videos/demo.mp4" type="video/mp4">
</video>
```
:::
````

### Images with Attributes

```markdown
![The task button showing a busy indication](task-button.gif){.shadow}
```

Or with more attributes:

```markdown
![Alt text](image.png){fig-alt="Detailed alt text" fig-align="center" width="100%"}
```

## Shinylive Examples

With the `shinylive` filter, you can embed live examples:

````markdown
```{shinylive-python}
#| standalone: true
#| components: [editor, viewer]

## file: app.py
from shiny.express import input, render, ui

# App code here
```
````

Or link to examples:

```markdown
We've added a [complete branded theming example](https://shinylive.io/py/examples/#branded-theming) to shinylive.io.
```

## Acknowledgements Section

Less consistent in Shiny posts. When present, variations include:

### Variation 1: Simple Thanks

```markdown
## Thanks!

Thank you for trying out the Shiny extension for VS Code!
If you find it helpful, please rate the extension on [the marketplace][Shiny extension].
```

### Variation 2: Multiple Package Releases

```markdown
## Release notes

**Big shout out to everyone involved!** 💙
We'd want to extend a huge thank you to everyone who contributed pull requests, bug reports and feature requests.

#### bslib [v0.7.0](https://rstudio.github.io/bslib/news/index.html#bslib-070)

[List of contributors]

#### shiny [v1.8.1](https://shiny.posit.co/r/reference/shiny/1.8.1/upgrade.html)

[List of contributors]
```

### Variation 3: Omitted

Some Shiny posts don't include acknowledgements, especially for announcements of tools rather than package releases.

### When Acknowledgements Are Included

Use similar format to Tidyverse:

```markdown
## Acknowledgements

We'd like to thank everyone who contributed to this release:

[@user1](https://github.com/user1), [@user2](https://github.com/user2), and [@user3](https://github.com/user3).
```

Or just reference the generator in code:

```markdown
```{r}
#| echo: false
#| eval: false
usethis::use_tidy_thanks("rstudio/bslib", from = "v0.6.1")
```
```

## CSS Customization

Shiny posts may include custom CSS in HTML blocks:

````markdown
```{=html}
<style>
img { border-radius: 8px; }
video {
  max-width: 100%;
  margin-bottom: 1rem;
}
</style>
```
````

## Column Layouts

Use Quarto's column classes for wider content:

```markdown
::: column-page
[Wide content here]
:::

::: column-body-outset
[Slightly wider content]
:::
```

## Footnotes

Use standard markdown footnotes:

```markdown
Text with a footnote[^footnote-key].

[^footnote-key]: This is the footnote text.
```

With `reference-location: document` or `section` in frontmatter to control placement.

## Links and References

Define link references at the top or bottom of the file:

```markdown
[brand.yml]: https://posit-dev.github.io/brand-yml
[quarto]: https://quarto.org
[shiny]: https://shiny.posit.co
```

Then use them inline:

```markdown
We're excited about [brand.yml] support!
```

## Multi-Language Support (R and Python)

The Shiny blog often covers packages released for both R and Python (e.g., shiny, shinychat). Unlike Tidyverse posts which are language-specific, Shiny posts should show examples in both languages using Quarto tabsets.

### Use Tabsets Consistently

Every code example should include both R and Python variants using Quarto tabsets:

```markdown
::: {.panel-tabset group="language"}
## R

```r
# R code here
```

## Python

```python
# Python code here
```
:::
```

**Guidelines:**
- Use `group="language"` to sync all language tabsets on the page
- Provide equivalent functionality in both languages
- Don't show R-only or Python-only examples unless the feature is language-specific
- Keep examples parallel—if the R example shows 5 lines, the Python example should be similar

### Installation Instructions

Always show installation for both languages at the start of the post:

```markdown
::: {.panel-tabset group="language"}
## R

```r
install.packages("packagename")
```

## Python

```bash
pip install packagename
```
:::
```

### Language-Specific Features

When features differ between languages, be explicit about the differences:

```markdown
::: {.panel-tabset group="language"}
## R

In R, use `tool_annotations()` to customize display:

```r
tool_annotations(title = "My Tool", icon = bsicons::bs_icon("star"))
```

## Python

In Python, use the `._display` attribute:

```python
my_tool._display = {"title": "My Tool", "icon": "star"}
```
:::
```

### Version Information

Package versions often differ between R and Python. Be explicit:

- "Available in shinychat for R (v0.3.0) and shinychat for Python (v0.2.0 or later)"
- Link to both language-specific documentation
- Include separate release notes links:
  ```markdown
  You can see the full list of changes in the [R release notes](url) and [Python release notes](url).
  ```

### When to Use Multi-Language Tabsets

- **Always use** for packages that have both R and Python versions (shiny, shinychat, querychat, etc.)
- **Don't use** for Python-only packages (shinyswatch) or R-only packages
- **Don't use** for Tidyverse blog posts (which are built with hugodown/Hugo, not Quarto)

## Example Complete Frontmatter

### Python Package

```yaml
---
title: shinyswatch 0.7.0
description: &desc Customizable shinyswatch themes and an improved theme picker round out shinyswatch v0.7.0.
author: "Garrick Aden-Buie"
date: "2024-07-19"

image: feature.jpg

open-graph:
  image: feature.jpg
  description: *desc
twitter-card:
  image: feature.png
  description: *desc

filters:
  - line-highlight
---
```

### R Package with Full Options

```yaml
---
title: "Shiny for R updates: Extended tasks, JavaScript errors, and many bslib improvements"
description: &desc |
  An overview of recent Shiny for R updates, including extended tasks, JavaScript errors, and many bslib improvements.
author:
  - Carson Sievert
date: "2024-03-27"

image: feature.png

open-graph:
  image: feature.png
  description: *desc
twitter-card:
  image: feature.png
  description: *desc

editor:
  render-on-save: true

engine: knitr

filters:
  - shinylive

freeze: true

format:
  html:
    code-link: true
    anchor-sections: true
    reference-location: section

code-annotations: hover
---
```

## Examples of Well-Formatted Posts

Reference these posts for formatting examples:
- [shinyswatch 0.7.0](https://shiny.posit.co/blog/posts/shinyswatch-0.7.0/)
- [Shiny Extension for VS Code 1.0.0](https://shiny.posit.co/blog/posts/shiny-vscode-1.0.0/)
- [Shiny for R 1.8.1](https://shiny.posit.co/blog/posts/shiny-r-1.8.1/)
- [Branded theming for Shiny for Python](https://shiny.posit.co/blog/posts/shiny-python-1.2-brand-yml/)
