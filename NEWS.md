# quarto 1.5.1

- Make sure tests pass on CRAN checks even when Quarto is not installed by adding a gihub action to test when no quarto is available. Also fix tests that were
not skipping when quarto was not available which failed on CRAN checks for MacOS and no binary were built. (thanks, @jabenninghoff, #282)

# quarto 1.5.0

## Breaking changes

- `quarto_render(output_file = )` now sets the `output-file` Quarto metadata 
  instead of the `--output` CLI flag to avoid current problems with Quarto 
  CLI. This allows the output file information to be correctly processed by 
  Quarto, as if passed in a YAML header, and enables support for multiple 
  output formats in the same render call. Users who need the old CLI flag 
  behavior can use `quarto_render(quarto_args = c('--output', 'filename'))` 
  (#251, #43).

- `quarto_use_template()` now fails with a clear error message when used in 
  non-empty directories, following a Quarto CLI update fix. Previously, the 
  function could work with interactive prompting, but this required user 
  interaction that isn't suitable for programmatic use. The function still 
  supports using templates in empty directories via the `dir` argument 
  (requires Quarto 1.5.15+). Follow quarto-dev/quarto-cli#11127 for changes 
  with `--no-prompt` behavior in future Quarto versions.

- YAML 1.2 compatibility features improved to ensure written YAML can be 
  properly read by Quarto's js-yaml parser. `write_yaml_metadata_block()` and 
  other YAML-writing functions now handle data corruption prevention from 
  leading zero strings like `"029"` that would be misinterpreted as octal 
  numbers (becoming `29`) (thanks, @Mosk915, quarto-dev/quarto-cli#12736, 
  #242). This change also benefits `quarto_render()` when using `metadata=`
  or `execute_params=` arguments.

- Internal YAML processing functions now detect and prevent NA values to 
  avoid incompatible YAML being sent to Quarto CLI. This prevents issues 
  where R's `NA` values get converted to YAML strings (like `.na.real`) that 
  Quarto doesn't recognize as missing values, since they are not supported 
  in YAML 1.2 spec. Code that previously passed NA values will now receive 
  clear error messages with actionable suggestions to handle missing data 
  appropriately before passing to Quarto (#168).

## New features

- `add_spin_preamble()` adds YAML preambles to R scripts for use with 
  Quarto Script rendering support. The function automatically detects 
  existing preambles and provides flexible customization options through 
  `title` and `preamble` parameters (#164).

- `check_newer_version()` checks online if a newer version of Quarto is 
  available. The function compares the current Quarto version against the 
  latest stable and prerelease versions. It is aimed for verbosity by 
  default (`verbose = TRUE`), but `verbose = FALSE` can also be set for 
  just checking update availability with TRUE or FALSE return values. 
  Version information is cached per session for up to 24 hours to minimize 
  network requests.

- `detect_bookdown_crossrefs()` helps users migrate from bookdown to 
  Quarto by identifying cross-references that need manual conversion. The 
  function scans R Markdown or Quarto files to detect bookdown-specific 
  cross-reference syntax (like `\@ref(fig:label)` and `(\#eq:label)`) and 
  provides detailed guidance on converting them to Quarto syntax (like 
  `@fig-label` and `{#eq-label}`). It offers both compact and verbose 
  reporting modes, with context-aware warnings that only show syntax 
  patterns actually found in your files.

- `find_project_root()`, `get_running_project_root()`, and 
  `project_path()` provide Quarto-aware project path construction. These 
  functions provide a consistent way to reference files relative to the 
  project root, working both during Quarto rendering (using 
  `QUARTO_PROJECT_ROOT` environment variables) and in interactive sessions 
  (using intelligent project detection). The `project_path()` function is 
  particularly useful in Quarto document cells where you need to reference 
  data files or scripts from the project root regardless of the document's 
  location in subdirectories (#180).

- `has_parameters()` detects whether Quarto documents use parameters. The 
  function works with both knitr and Jupyter engines: for documents using 
  the knitr engine, it checks for a `params` field in the document YAML 
  metadata header; for documents using the Jupyter engine (.qmd with jupyter 
  engine or .ipynb notebooks), it detects cells tagged with `"parameters"` 
  using papermill convention. This enables programmatic identification of 
  parameterized documents for automated workflows and document processing 
  (#245).

- `new_blog_post()` creates new blog posts for Quarto blog (thanks, @topeto, #22).

- `qmd_to_r_script()` extracts R code cells from Quarto documents and 
  creates R scripts. This experimental function preserves chunk options 
  using `#|` syntax, adds YAML metadata as spin-style headers, handles 
  mixed-language documents by filtering only R cells, skips chunks with 
  `purl: false`, and properly processes `eval: false` chunks by commenting 
  out their code. Complements the existing `add_spin_preamble()` function 
  for working with R scripts in Quarto workflows (#208, #277, quarto-dev/quarto-cli#9112).

- `quarto_available()` checks if Quarto CLI is found (thanks, @hadley, 
  #187).

- `quarto_list_extensions()`, `quarto_remove_extension()`, and 
  `quarto_update_extension()` provide new wrapper functions for extension 
  management (thanks, @parmsam, #192). These functions wrap 
  `quarto list extensions`, `quarto remove extensions`, and `quarto update extensions` 
  respectively.

- `tbl_qmd_span()` and `tbl_qmd_div()` create HTML elements 
  with special `data-qmd` attributes that tell Quarto to process their 
  content as Markdown. These functions enable including formatted text, math 
  equations, links, and other Markdown content within HTML tables generated 
  by packages like **knitr**, **kableExtra**, and **DT**. The functions 
  provide a `display` argument for fallback text when content includes 
  Quarto-specific features like shortcodes. This addresses a common 
  limitation where Markdown syntax inside HTML tables isn't automatically 
  processed by Quarto. Additional convenience functions `tbl_qmd_span_base64()`, 
  `tbl_qmd_div_base64()`, `tbl_qmd_span_raw()`, and `tbl_qmd_div_raw()` 
  provide explicit control over encoding.

- `theme_brand_*()` and `theme_colors_*()` helper functions assist with 
  theming using dark and light brand colors for common graph and table 
  packages (thanks, @gordonwoodhull, #234). The functions support **ggplot2** 
  (`theme_brand_ggplot2()`, `theme_colors_ggplot2()`), **gt** 
  (`theme_brand_gt()`, `theme_colors_gt()`), **flextable** 
  (`theme_brand_flextable()`, `theme_colors_flextable()`), **plotly** 
  (`theme_brand_plotly()`, `theme_colors_plotly()`), and **thematic** 
  (`theme_brand_thematic()`, `theme_colors_thematic()`).

- `write_yaml_metadata_block()` dynamically sets YAML metadata in Quarto 
  documents from R code chunks. This addresses the limitation where Quarto 
  metadata must be static and defined in the document header. The function 
  enables conditional content and metadata-driven document behavior based 
  on R computations (thanks, @kmasiello, #137, #160).

- `yaml_quote_string()` allows explicit control over string quoting in 
  YAML output.

## Minor improvements and fixes

- Debugging logic added for quarto vignette engine to help diagnose issues 
  with Quarto vignettes in **pkgdown** and other contexts (thanks, @hadley, 
  #185). Set `quarto.log.debug = TRUE` to enable debugging messages (or 
  `R_QUARTO_LOG_DEBUG = TRUE` environment variable). Set `quarto.log.file` 
  to change the file path to write to (or `R_QUARTO_LOG_FILE` environment 
  variable). Default will be `./quarto-r-debug.log`. Debug mode will be on 
  automatically when debugging Github Actions workflows, or when Quarto 
  CLI's environment variable `QUARTO_LOG_LEVEL` is set to `DEBUG`.

- Error reporting improved when background process call to `quarto` fails 
  (thanks, @salim-b, #235).

- Interactive prompt error fixed for extension approval (thanks, @wjschne, 
  #212).

- Package is now licensed MIT like Quarto CLI.

- `quarto_create_project()` gains a `title` argument to set the project 
  title independently from the directory name. This allows creating 
  projects with custom titles, including when using `name = "."` to create 
  a project in the current directory (thanks, @davidkane9, #148). This 
  matches with `--title` addition for `quarto create project` in Quarto 
  CLI v1.5.15.

- `quarto_create_project()` offers better user experience (thanks, 
  @jennybc, #206, #153).

- `quarto_path()` now correctly returns `NULL` when no quarto is found in 
  the PATH (thanks, @jeroen, #220, #221).

- `quarto_path()` now returns a normalized path with potential symlink 
  resolved, for less confusion with `quarto_binary_sitrep()` (thanks, 
  @jennybc).

- `quarto_preview()` gains a `quiet` argument to suppress any output from 
  R or Quarto CLI (thanks, @cwickham, #232).

- `quarto_preview()` now explicitly returns the preview server URL 
  (invisibly) and documents this behavior. This enables programmatic 
  workflows such as taking screenshots with **webshot2** or passing the 
  URL to other automation tools (thanks, @cwickham, #233).

- `quarto_render()` now correctly sets `as_job` when not inside RStudio 
  IDE and required **rstudioapi** functions are not available (#203).

- `quarto_render(as_job = TRUE)` is now wrappable (thanks, @salim-b, #105).

- `quarto.quiet` option added to allow more verbose error messages when 
  `quarto_*` functions are used inside other packages. For example, inside 
  **pkgdown** for building Quarto vignettes. **pkgdown** sets `quiet = 
  TRUE` internally for its call to `quarto_render()`, and setting 
  `options(quarto.quiet = TRUE)` allows to overwrite this.

- `R_QUARTO_QUIET` environment variable can be used to set `quarto.quiet` 
  option, which overrides any `quiet = TRUE` argument passed to `quarto_*` 
  functions. This can be useful to debug Quarto rendering inside other 
  packages, like **pkgdown**. Overrides will also now happen for GHA debug 
  logging.

- R version consistency improved: Quarto CLI will now correctly use the 
  same R version as the one used to run functions in this package (#204).

# quarto 1.4.4

- `quarto_preview()` now looks at `quarto preview` log to browse to the correct url when inside RStudio viewer (thanks, @aronatkins, #167).

- This package now uses the x.y.z.dev versionning scheme to indicate development, patch, minor and major versions. This follows [Tidyverse package version conventions](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number-tidyverse).

- Adapt tests for CRAN checks issues due to Quarto v1.5.54 regression (though it is fixed upstream).

- Approval check in `quarto_add_extension()` and `quarto_use_template()` now works correctly (thanks, @eveyp, #172).

# quarto 1.4

- This version is now adapted to Quarto 1.4 latest stable release.

- Add registration of vignette engine to use `quarto` as a vignette builder, and use `.qmd` file as vignette. See `vignette("hello", package = "quarto")`. (thanks, @dcnorris, #57).

- New `quarto_binary_sitrep()` checks possible difference in Quarto binary used by this package, and the one used by RStudio IDE (thanks, @jthomasmock, #12).
  
- New `is_using_quarto()` to check if a directory requires using Quarto (i.e. it has a `_quarto.yml` or at least one `*.qmd` file) (thanks, @hadley, #103).

- New `quarto_create_project()` calls `quarto create project <type> <name>` (thanks, @maelle, #87).

- New `quarto_add_extension()` and `quarto_use_template()` to deal with Quarto extensions for a Quarto project. (thanks, @mcanouil, #45, @remlapmot, #42).

- `quarto_render()` and `quarto_inspect()` gains a `profile` argument (thanks, @andrewheiss, #95, @salim-b, #123).

- `quarto_render()` gains `metadata` and `metadata_file` arguments. They can be used to pass modified Quarto metadata at render time. If both are set, `metadata` will be merged over `metadata_file` content. Internally, metadata will be passed as a `--metadata-file` to `quarto render` (thanks, @mcanouil, #52, @maelle, #49).

- `quarto_render()` and all other relevant functions gain a `quarto_args` argument. It allows to pass additional options flag to `quarto` CLI. This is for advanced usage e.g. when new options are added to Quarto CLI that would not be user-facing in this package's functions (thanks, @gadenbuie, #125).

- Add `quiet` argument in most functions to remove warnings and messages. It default to `FALSE` in most function to match with `quarto` CLI default.

- In `quarto_render()`, `execute_params` now converts boolean value to `true/false` correctly as expected by `quarto render` (thanks, @marianklose, #124).

- Error message now advises to re-run with `quiet = FALSE` because `quarto_render(quiet = TRUE)` will run `quarto render` in quiet mode (thanks to @gadenbuie, #126, @wlandau, #16).

- **rsconnect** R package dependency has been moved to Suggest to reduce this package's overall number of dependencies. **rsconnect** package is only required for publishing using `quarto_publish_*()` functions. Users will be prompted to install (when in interactive mode) if not installed.

- Added a `NEWS.md` file to track changes to the package.
