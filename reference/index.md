# Package index

## Render and Preview

The following functions enable you to render and preview Quarto
documents and projects:

- [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md)
  : Render Markdown
- [`quarto_preview()`](https://quarto-dev.github.io/quarto-r/reference/quarto_preview.md)
  [`quarto_preview_stop()`](https://quarto-dev.github.io/quarto-r/reference/quarto_preview.md)
  : Quarto Preview
- [`quarto_serve()`](https://quarto-dev.github.io/quarto-r/reference/quarto_serve.md)
  : Serve Interactive Document

## Publishing

These functions enable you to publish static and interactive documents,
websites, and books to [Posit
Connect](https://posit.co/products/enterprise/connect/) and
[shinyapps.io](https://www.shinyapps.io/):

- [`quarto_publish_doc()`](https://quarto-dev.github.io/quarto-r/reference/quarto_publish_doc.md)
  [`quarto_publish_app()`](https://quarto-dev.github.io/quarto-r/reference/quarto_publish_doc.md)
  [`quarto_publish_site()`](https://quarto-dev.github.io/quarto-r/reference/quarto_publish_doc.md)
  : Publish Quarto Documents

## Extensions

These functions enable you to manage Quarto extensions and use template
from extensions in your folder and projects. More about Quarto
extensions at <https://quarto.org/docs/extensions/>

- [`quarto_add_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_add_extension.md)
  : Install a Quarto extensions
- [`quarto_remove_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_remove_extension.md)
  : Remove a Quarto extensions
- [`quarto_update_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_update_extension.md)
  : Update a Quarto extensions
- [`quarto_list_extensions()`](https://quarto-dev.github.io/quarto-r/reference/quarto_list_extensions.md)
  : List Installed Quarto extensions
- [`quarto_use_template()`](https://quarto-dev.github.io/quarto-r/reference/quarto_use_template.md)
  : Use a custom format extension template

## Projects

This functions enable you to work with projects. More about Quarto
extensions at <https://quarto.org/docs/projects/quarto-projects.html>

- [`quarto_create_project()`](https://quarto-dev.github.io/quarto-r/reference/quarto_create_project.md)
  : Create a quarto project
- [`new_blog_post()`](https://quarto-dev.github.io/quarto-r/reference/new_blog_post.md)
  : Create a new blog post
- [`project_path()`](https://quarto-dev.github.io/quarto-r/reference/project_path.md)
  **\[experimental\]** : Get path relative to project root
  (Quarto-aware)
- [`find_project_root()`](https://quarto-dev.github.io/quarto-r/reference/find_project_root.md)
  : Find the root of a Quarto project
- [`get_running_project_root()`](https://quarto-dev.github.io/quarto-r/reference/get_running_project_root.md)
  : Get the root of the currently running Quarto project

## Configuration

These functions enable you to inspect the Quarto installation as well as
the metadata for Quarto documents and projects:

- [`quarto_inspect()`](https://quarto-dev.github.io/quarto-r/reference/quarto_inspect.md)
  : Inspect Quarto Input File or Project
- [`has_parameters()`](https://quarto-dev.github.io/quarto-r/reference/has_parameters.md)
  : Check if a Quarto document uses parameters
- [`quarto_path()`](https://quarto-dev.github.io/quarto-r/reference/quarto_path.md)
  : Path to the quarto binary
- [`quarto_version()`](https://quarto-dev.github.io/quarto-r/reference/quarto_version.md)
  : Check quarto version
- [`quarto_available()`](https://quarto-dev.github.io/quarto-r/reference/quarto_available.md)
  : Check if quarto is available and version meet some requirements
- [`is_using_quarto()`](https://quarto-dev.github.io/quarto-r/reference/is_using_quarto.md)
  : Check is a directory is using quarto
- [`quarto_binary_sitrep()`](https://quarto-dev.github.io/quarto-r/reference/quarto_binary_sitrep.md)
  : Check configurations for quarto binary used
- [`check_newer_version()`](https://quarto-dev.github.io/quarto-r/reference/check_newer_version.md)
  : Check for newer version of Quarto

## Theme Helpers

These simple helper functions adapt plotting and table packages to use
background and foreground colors, or brand.yml colors.

- [`theme_colors_flextable()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_brand_flextable()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_colors_ggplot2()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_brand_ggplot2()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_colors_gt()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_brand_gt()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_colors_plotly()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_brand_plotly()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_colors_thematic()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  [`theme_brand_thematic()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)
  : Create a theme for a plotting or table package

## Table Helpers

These functions are used to help with tables in Quarto documents:

- [`tbl_qmd_span()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  [`tbl_qmd_div()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  [`tbl_qmd_span_base64()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  [`tbl_qmd_div_base64()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  [`tbl_qmd_span_raw()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  [`tbl_qmd_div_raw()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  : Create Quarto Markdown HTML Elements for Tables

## YAML Helpers

These functions are used to help with YAML metadata in Quarto documents:

- [`write_yaml_metadata_block()`](https://quarto-dev.github.io/quarto-r/reference/write_yaml_metadata_block.md)
  : Write YAML Metadata Block for Quarto Documents
- [`yaml_quote_string()`](https://quarto-dev.github.io/quarto-r/reference/yaml_quote_string.md)
  : Add quoted attribute to strings for YAML output

## Miscellaneous

These functions are used to help with Quarto documents and projects:

- [`add_spin_preamble()`](https://quarto-dev.github.io/quarto-r/reference/add_spin_preamble.md)
  : Add spin preamble to R script
- [`qmd_to_r_script()`](https://quarto-dev.github.io/quarto-r/reference/qmd_to_r_script.md)
  **\[experimental\]** : Convert Quarto document to R script
- [`detect_bookdown_crossrefs()`](https://quarto-dev.github.io/quarto-r/reference/detect_bookdown_crossrefs.md)
  : Detect Bookdown Cross-References for Quarto Migration
