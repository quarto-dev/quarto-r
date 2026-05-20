# Tidyverse Blog Formatting Conventions

Tidyverse-specific formatting requirements for blog posts on tidyverse.org. These conventions are for the hugodown-based Tidyverse blog.

## Workflow for tidyverse.org Blog

When creating a blog post for the official `tidyverse/tidyverse.org` repository, follow these steps:

1. **Install hugodown** (if not already installed):
   ```r
   pak::pkg_install("r-lib/hugodown")
   ```

2. **Create a new post**:
   ```r
   hugodown::use_tidy_post("short-name")
   ```

   This creates `content/blog/short-name/` containing an `index.Rmd` file.

   Common patterns for `"short-name"`:
   - Package release: `lifecycle-1-0-0`, `parsnip-0-1-2`
   - Package release with specific topic: `dplyr-1-0-0-rowwise`, `parsnip-adjacent`, `dplyr-1-0-4-if-any`
   - Topic only: `self-cleaning-test-fixtures`, `taking-control-of-plot-scaling`

3. **Write and knit**:
   - Edit the generated `index.Rmd` file
   - Knit `index.Rmd` to generate `index.md`
   - Note: `.Rmd` files are only rendered when you explicitly knit them

4. **Preview the site**:
   ```r
   hugodown::hugo_start()
   ```
   This runs once per session and continues in the background to turn `.md` into `.html`.

5. **Check for outdated files** (if concerned):
   ```r
   hugodown::site_outdated()
   ```
   Lists all `.Rmd`s that need to be re-rendered.

6. **Add a photo**:
   Every blog post must be accompanied by a photo. If you don't have one in mind, try:
   - <https://unsplash.com>
   - <https://pexels.com>
   - Jenny Bryan's [free photo](https://github.com/jennybc/free-photos) link collection

7. **Submit PR**:
   - Every PR gets an automatic live preview via Netlify
   - Once merged, the preview becomes the live site

### Important Notes

- The site uses **hugodown** (not blogdown), which separates building into two steps:
  - hugodown generates `.md` from `.Rmd`
  - hugo generates `.html` from `.md`
- Use `.Rmd` files (not `.Rmarkdown`)
- Output should be `output: hugodown::hugo_document`
- If updating an old post to use hugodown:
  - Rename from `.Rmarkdown` to `.Rmd`
  - Delete the `.markdown` file
  - Set `output: hugodown::hugo_document` in YAML metadata

### For Additional Context

If you need more details about the workflow or encounter issues, consult the `README.md` in the `tidyverse/tidyverse.org` repository.

## Frontmatter Format

Tidyverse blog posts use YAML frontmatter with this structure:

```yaml
---
output: hugodown::hugo_document
slug: package-name-version
title: package-name version
date: YYYY-MM-DD
author: Author Name
description: >
    Brief description of the package and release
photo:
  url: https://unsplash.com/photos/photo-id
  author: Photographer Name
categories: [package-name]
tags: [package-name, category]
---
```

### Required Fields

- **`output`**: Always `hugodown::hugo_document`
- **`slug`**: URL slug using hyphens
  - Format: `packagename-x-y-z` (e.g., `ellmer-0-4-0`)
  - Replace dots with hyphens in version numbers
- **`title`**: Display title with spaces
  - Format: `packagename x.y.z` (e.g., `ellmer 0.4.0`)
- **`date`**: ISO format `YYYY-MM-DD`
- **`author`**: Full name of primary author
- **`description`**: Brief summary (can use `>` for multi-line)
- **`photo`**: Featured image with attribution
  - `url`: Full URL to image (often Unsplash)
  - `author`: Photographer name for attribution
- **`categories`**: Array with package name
- **`tags`**: Array with package name and related tags

### Slug vs Title Convention

The slug is used in URLs and must be URL-safe:
- Slug: `purrr-1-2-0` (hyphens, no dots)
- Title: `purrr 1.2.0` (space, dots in version)

### Image Attribution

Featured images are typically from Unsplash with proper photographer attribution:

```yaml
photo:
  url: https://unsplash.com/photos/abc123
  author: John Doe
```

## Title Format

The main title uses a simple format with space between package name and version:

```markdown
# packagename 1.2.0
```

No "released" or "version" prefix. Just the package name and version number.

## Code Formatting

### Language Identifiers

Use triple backticks with `r` language identifier for R code:

````markdown
```r
library(packagename)

result <- function_name(
  arg1 = "value",
  arg2 = TRUE
)
```
````

For installation:
````markdown
```r
install.packages("packagename")
```
````

### Inline Code Elements

- Function names: `` `function()` ``
- Packages: `` `{packagename}` `` when emphasizing it's a package
- Arguments: `` `arg = value` ``
- Values: `` `NULL` ``, `` `TRUE` ``, `` `"string"` ``

### Function Links

When linking to function documentation, use markdown links:

```markdown
[`function_name()`](https://url-to-docs)
```

## Section Structure

### Lifecycle Section Format

When including lifecycle changes, use this structure:

```markdown
## Lifecycle changes

* **Fully removed** after 5+ years of deprecation:
  * `function1()` - use `replacement1()` instead
  * `function2()` - use `replacement2()` instead

* **Newly deprecated** (soft-deprecation):
  * `function3()` is superseded by `function4()`
  * `function5()` is no longer recommended

* **Breaking changes**:
  * Description of what changed and why
```

Use bold for the lifecycle stage labels.

### Feature Sections

Use sentence case in headings:

```markdown
## Easier `in_parallel()`

[Description of the feature...]
```

Include function names in backticks when they're part of the heading.

## Acknowledgements Section

Always include as the final section:

```markdown
## Acknowledgements

A big thank you to all the folks who helped make this release happen:

[@username1](https://github.com/username1), [@username2](https://github.com/username2), [@username3](https://github.com/username3), and [@username4](https://github.com/username4).
```

### Formatting Rules

- Single paragraph format (not bulleted list)
- GitHub handles as markdown links
- Alphabetical order
- Comma-separated with "and" before the last name
- Period at the end

### Generating the List

Use `usethis::use_tidy_thanks()`:

```r
# Fetch contributors since last release
usethis::use_tidy_thanks("tidyverse/packagename")

# Or from specific tag
usethis::use_tidy_thanks("tidyverse/packagename", from = "v1.0.0")
```

This function outputs properly formatted markdown that can be copied directly into the blog post.

## Release Notes Link

Include a link to the full release notes (typically on pkgdown site):

```markdown
You can see a full list of changes in the [release notes](https://packagename.tidyverse.org/news/).
```

## Example Complete Frontmatter

```yaml
---
output: hugodown::hugo_document
slug: purrr-1-2-0
title: purrr 1.2.0
date: 2025-11-04
author: Hadley Wickham
description: >
    purrr 1.2.0 includes deprecations and minor enhancements to
    functional programming tools in R.
photo:
  url: https://unsplash.com/photos/xyz789
  author: Jane Photographer
categories: [purrr]
tags: [purrr, tidyverse]
---
```

## Examples of Well-Formatted Posts

Reference these posts for formatting examples:
- [pkgdown 2.2.0](https://www.tidyverse.org/blog/2025/11/pkgdown-2-2-0/)
- [testthat 3.3.0](https://www.tidyverse.org/blog/2025/11/testthat-3-3-0/)
- [purrr 1.2.0](https://www.tidyverse.org/blog/2025/11/purrr-1-2-0/)
- [ellmer 0.4.0](https://www.tidyverse.org/blog/2025/11/ellmer-0-4-0/)
