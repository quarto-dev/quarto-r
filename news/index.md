# Changelog

## quarto (development version)

- [`.libPaths()`](https://rdrr.io/r/base/libPaths.html) from the calling
  R session will now be passed by default to all call to quarto as a
  subprocess. This should solve issue with **pkgdown** or when building
  vignettes.

- Curly braces in Quarto CLI error messages are now escaped to prevent
  them from being interpreted as `cli` formatting syntax
  ([\#293](https://github.com/quarto-dev/quarto-r/issues/293)).

## quarto 1.5.1

CRAN release: 2025-09-04

- Make sure tests pass on CRAN checks even when Quarto is not installed
  by adding a gihub action to test when no quarto is available. Also fix
  tests that were not skipping when quarto was not available which
  failed on CRAN checks for MacOS and no binary were built. (thanks,
  [@jabenninghoff](https://github.com/jabenninghoff),
  [\#282](https://github.com/quarto-dev/quarto-r/issues/282))

## quarto 1.5.0

CRAN release: 2025-07-28

### Breaking changes

- `quarto_render(output_file = )` now sets the `output-file` Quarto
  metadata instead of the `--output` CLI flag to avoid current problems
  with Quarto

  151. This allows the output file information to be correctly processed
       by Quarto, as if passed in a YAML header, and enables support for
       multiple output formats in the same render call. Users who need
       the old CLI flag behavior can use
       `quarto_render(quarto_args = c('--output', 'filename'))`
       ([\#251](https://github.com/quarto-dev/quarto-r/issues/251),
       [\#43](https://github.com/quarto-dev/quarto-r/issues/43)).

- [`quarto_use_template()`](https://quarto-dev.github.io/quarto-r/reference/quarto_use_template.md)
  now fails with a clear error message when used in non-empty
  directories, following a Quarto CLI update fix. Previously, the
  function could work with interactive prompting, but this required user
  interaction that isn’t suitable for programmatic use. The function
  still supports using templates in empty directories via the `dir`
  argument (requires Quarto 1.5.15+). Follow quarto-dev/quarto-cli#11127
  for changes with `--no-prompt` behavior in future Quarto versions.

- YAML 1.2 compatibility features improved to ensure written YAML can be
  properly read by Quarto’s js-yaml parser.
  [`write_yaml_metadata_block()`](https://quarto-dev.github.io/quarto-r/reference/write_yaml_metadata_block.md)
  and other YAML-writing functions now handle data corruption prevention
  from leading zero strings like `"029"` that would be misinterpreted as
  octal numbers (becoming `29`) (thanks,
  [@Mosk915](https://github.com/Mosk915), quarto-dev/quarto-cli#12736,
  [\#242](https://github.com/quarto-dev/quarto-r/issues/242)). This
  change also benefits
  [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md)
  when using `metadata=` or `execute_params=` arguments.

- Internal YAML processing functions now detect and prevent NA values to
  avoid incompatible YAML being sent to Quarto CLI. This prevents issues
  where R’s `NA` values get converted to YAML strings (like `.na.real`)
  that Quarto doesn’t recognize as missing values, since they are not
  supported in YAML 1.2 spec. Code that previously passed NA values will
  now receive clear error messages with actionable suggestions to handle
  missing data appropriately before passing to Quarto
  ([\#168](https://github.com/quarto-dev/quarto-r/issues/168)).

### New features

- [`add_spin_preamble()`](https://quarto-dev.github.io/quarto-r/reference/add_spin_preamble.md)
  adds YAML preambles to R scripts for use with Quarto Script rendering
  support. The function automatically detects existing preambles and
  provides flexible customization options through `title` and `preamble`
  parameters
  ([\#164](https://github.com/quarto-dev/quarto-r/issues/164)).

- [`check_newer_version()`](https://quarto-dev.github.io/quarto-r/reference/check_newer_version.md)
  checks online if a newer version of Quarto is available. The function
  compares the current Quarto version against the latest stable and
  prerelease versions. It is aimed for verbosity by default
  (`verbose = TRUE`), but `verbose = FALSE` can also be set for just
  checking update availability with TRUE or FALSE return values. Version
  information is cached per session for up to 24 hours to minimize
  network requests.

- [`detect_bookdown_crossrefs()`](https://quarto-dev.github.io/quarto-r/reference/detect_bookdown_crossrefs.md)
  helps users migrate from bookdown to Quarto by identifying
  cross-references that need manual conversion. The function scans R
  Markdown or Quarto files to detect bookdown-specific cross-reference
  syntax (like `\@ref(fig:label)` and `(\#eq:label)`) and provides
  detailed guidance on converting them to Quarto syntax (like
  `@fig-label` and `{#eq-label}`). It offers both compact and verbose
  reporting modes, with context-aware warnings that only show syntax
  patterns actually found in your files.

- [`find_project_root()`](https://quarto-dev.github.io/quarto-r/reference/find_project_root.md),
  [`get_running_project_root()`](https://quarto-dev.github.io/quarto-r/reference/get_running_project_root.md),
  and
  [`project_path()`](https://quarto-dev.github.io/quarto-r/reference/project_path.md)
  provide Quarto-aware project path construction. These functions
  provide a consistent way to reference files relative to the project
  root, working both during Quarto rendering (using
  `QUARTO_PROJECT_ROOT` environment variables) and in interactive
  sessions (using intelligent project detection). The
  [`project_path()`](https://quarto-dev.github.io/quarto-r/reference/project_path.md)
  function is particularly useful in Quarto document cells where you
  need to reference data files or scripts from the project root
  regardless of the document’s location in subdirectories
  ([\#180](https://github.com/quarto-dev/quarto-r/issues/180)).

- [`has_parameters()`](https://quarto-dev.github.io/quarto-r/reference/has_parameters.md)
  detects whether Quarto documents use parameters. The function works
  with both knitr and Jupyter engines: for documents using the knitr
  engine, it checks for a `params` field in the document YAML metadata
  header; for documents using the Jupyter engine (.qmd with jupyter
  engine or .ipynb notebooks), it detects cells tagged with
  `"parameters"` using papermill convention. This enables programmatic
  identification of parameterized documents for automated workflows and
  document processing
  ([\#245](https://github.com/quarto-dev/quarto-r/issues/245)).

- [`new_blog_post()`](https://quarto-dev.github.io/quarto-r/reference/new_blog_post.md)
  creates new blog posts for Quarto blog (thanks,
  [@topeto](https://github.com/topeto),
  [\#22](https://github.com/quarto-dev/quarto-r/issues/22)).

- [`qmd_to_r_script()`](https://quarto-dev.github.io/quarto-r/reference/qmd_to_r_script.md)
  extracts R code cells from Quarto documents and creates R scripts.
  This experimental function preserves chunk options using `#|` syntax,
  adds YAML metadata as spin-style headers, handles mixed-language
  documents by filtering only R cells, skips chunks with `purl: false`,
  and properly processes `eval: false` chunks by commenting out their
  code. Complements the existing
  [`add_spin_preamble()`](https://quarto-dev.github.io/quarto-r/reference/add_spin_preamble.md)
  function for working with R scripts in Quarto workflows
  ([\#208](https://github.com/quarto-dev/quarto-r/issues/208),
  [\#277](https://github.com/quarto-dev/quarto-r/issues/277),
  quarto-dev/quarto-cli#9112).

- [`quarto_available()`](https://quarto-dev.github.io/quarto-r/reference/quarto_available.md)
  checks if Quarto CLI is found (thanks,
  [@hadley](https://github.com/hadley),
  [\#187](https://github.com/quarto-dev/quarto-r/issues/187)).

- [`quarto_list_extensions()`](https://quarto-dev.github.io/quarto-r/reference/quarto_list_extensions.md),
  [`quarto_remove_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_remove_extension.md),
  and
  [`quarto_update_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_update_extension.md)
  provide new wrapper functions for extension management (thanks,
  [@parmsam](https://github.com/parmsam),
  [\#192](https://github.com/quarto-dev/quarto-r/issues/192)). These
  functions wrap `quarto list extensions`, `quarto remove extensions`,
  and `quarto update extensions` respectively.

- [`tbl_qmd_span()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  and
  [`tbl_qmd_div()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  create HTML elements with special `data-qmd` attributes that tell
  Quarto to process their content as Markdown. These functions enable
  including formatted text, math equations, links, and other Markdown
  content within HTML tables generated by packages like **knitr**,
  **kableExtra**, and **DT**. The functions provide a `display` argument
  for fallback text when content includes Quarto-specific features like
  shortcodes. This addresses a common limitation where Markdown syntax
  inside HTML tables isn’t automatically processed by Quarto. Additional
  convenience functions
  [`tbl_qmd_span_base64()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md),
  [`tbl_qmd_div_base64()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md),
  [`tbl_qmd_span_raw()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md),
  and
  [`tbl_qmd_div_raw()`](https://quarto-dev.github.io/quarto-r/reference/tbl_qmd_elements.md)
  provide explicit control over encoding.

- `theme_brand_*()` and `theme_colors_*()` helper functions assist with
  theming using dark and light brand colors for common graph and table
  packages (thanks,
  [@gordonwoodhull](https://github.com/gordonwoodhull),
  [\#234](https://github.com/quarto-dev/quarto-r/issues/234)). The
  functions support **ggplot2**
  ([`theme_brand_ggplot2()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md),
  [`theme_colors_ggplot2()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)),
  **gt**
  ([`theme_brand_gt()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md),
  [`theme_colors_gt()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)),
  **flextable**
  ([`theme_brand_flextable()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md),
  [`theme_colors_flextable()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)),
  **plotly**
  ([`theme_brand_plotly()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md),
  [`theme_colors_plotly()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)),
  and **thematic**
  ([`theme_brand_thematic()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md),
  [`theme_colors_thematic()`](https://quarto-dev.github.io/quarto-r/reference/theme_helpers.md)).

- [`write_yaml_metadata_block()`](https://quarto-dev.github.io/quarto-r/reference/write_yaml_metadata_block.md)
  dynamically sets YAML metadata in Quarto documents from R code chunks.
  This addresses the limitation where Quarto metadata must be static and
  defined in the document header. The function enables conditional
  content and metadata-driven document behavior based on R computations
  (thanks, [@kmasiello](https://github.com/kmasiello),
  [\#137](https://github.com/quarto-dev/quarto-r/issues/137),
  [\#160](https://github.com/quarto-dev/quarto-r/issues/160)).

- [`yaml_quote_string()`](https://quarto-dev.github.io/quarto-r/reference/yaml_quote_string.md)
  allows explicit control over string quoting in YAML output.

### Minor improvements and fixes

- Debugging logic added for quarto vignette engine to help diagnose
  issues with Quarto vignettes in **pkgdown** and other contexts
  (thanks, [@hadley](https://github.com/hadley),
  [\#185](https://github.com/quarto-dev/quarto-r/issues/185)). Set
  `quarto.log.debug = TRUE` to enable debugging messages (or
  `R_QUARTO_LOG_DEBUG = TRUE` environment variable). Set
  `quarto.log.file` to change the file path to write to (or
  `R_QUARTO_LOG_FILE` environment variable). Default will be
  `./quarto-r-debug.log`. Debug mode will be on automatically when
  debugging Github Actions workflows, or when Quarto CLI’s environment
  variable `QUARTO_LOG_LEVEL` is set to `DEBUG`.

- Error reporting improved when background process call to `quarto`
  fails (thanks, [@salim-b](https://github.com/salim-b),
  [\#235](https://github.com/quarto-dev/quarto-r/issues/235)).

- Interactive prompt error fixed for extension approval (thanks,
  [@wjschne](https://github.com/wjschne),
  [\#212](https://github.com/quarto-dev/quarto-r/issues/212)).

- Package is now licensed MIT like Quarto CLI.

- [`quarto_create_project()`](https://quarto-dev.github.io/quarto-r/reference/quarto_create_project.md)
  gains a `title` argument to set the project title independently from
  the directory name. This allows creating projects with custom titles,
  including when using `name = "."` to create a project in the current
  directory (thanks, [@davidkane9](https://github.com/davidkane9),
  [\#148](https://github.com/quarto-dev/quarto-r/issues/148)). This
  matches with `--title` addition for `quarto create project` in Quarto
  CLI v1.5.15.

- [`quarto_create_project()`](https://quarto-dev.github.io/quarto-r/reference/quarto_create_project.md)
  offers better user experience (thanks,
  [@jennybc](https://github.com/jennybc),
  [\#206](https://github.com/quarto-dev/quarto-r/issues/206),
  [\#153](https://github.com/quarto-dev/quarto-r/issues/153)).

- [`quarto_path()`](https://quarto-dev.github.io/quarto-r/reference/quarto_path.md)
  now correctly returns `NULL` when no quarto is found in the PATH
  (thanks, [@jeroen](https://github.com/jeroen),
  [\#220](https://github.com/quarto-dev/quarto-r/issues/220),
  [\#221](https://github.com/quarto-dev/quarto-r/issues/221)).

- [`quarto_path()`](https://quarto-dev.github.io/quarto-r/reference/quarto_path.md)
  now returns a normalized path with potential symlink resolved, for
  less confusion with
  [`quarto_binary_sitrep()`](https://quarto-dev.github.io/quarto-r/reference/quarto_binary_sitrep.md)
  (thanks, [@jennybc](https://github.com/jennybc)).

- [`quarto_preview()`](https://quarto-dev.github.io/quarto-r/reference/quarto_preview.md)
  gains a `quiet` argument to suppress any output from R or Quarto CLI
  (thanks, [@cwickham](https://github.com/cwickham),
  [\#232](https://github.com/quarto-dev/quarto-r/issues/232)).

- [`quarto_preview()`](https://quarto-dev.github.io/quarto-r/reference/quarto_preview.md)
  now explicitly returns the preview server URL (invisibly) and
  documents this behavior. This enables programmatic workflows such as
  taking screenshots with **webshot2** or passing the URL to other
  automation tools (thanks, [@cwickham](https://github.com/cwickham),
  [\#233](https://github.com/quarto-dev/quarto-r/issues/233)).

- [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md)
  now correctly sets `as_job` when not inside RStudio IDE and required
  **rstudioapi** functions are not available
  ([\#203](https://github.com/quarto-dev/quarto-r/issues/203)).

- `quarto_render(as_job = TRUE)` is now wrappable (thanks,
  [@salim-b](https://github.com/salim-b),
  [\#105](https://github.com/quarto-dev/quarto-r/issues/105)).

- `quarto.quiet` option added to allow more verbose error messages when
  `quarto_*` functions are used inside other packages. For example,
  inside **pkgdown** for building Quarto vignettes. **pkgdown** sets
  `quiet = TRUE` internally for its call to
  [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md),
  and setting `options(quarto.quiet = TRUE)` allows to overwrite this.

- `R_QUARTO_QUIET` environment variable can be used to set
  `quarto.quiet` option, which overrides any `quiet = TRUE` argument
  passed to `quarto_*` functions. This can be useful to debug Quarto
  rendering inside other packages, like **pkgdown**. Overrides will also
  now happen for GHA debug logging.

- R version consistency improved: Quarto CLI will now correctly use the
  same R version as the one used to run functions in this package
  ([\#204](https://github.com/quarto-dev/quarto-r/issues/204)).

## quarto 1.4.4

CRAN release: 2024-07-20

- [`quarto_preview()`](https://quarto-dev.github.io/quarto-r/reference/quarto_preview.md)
  now looks at `quarto preview` log to browse to the correct url when
  inside RStudio viewer (thanks,
  [@aronatkins](https://github.com/aronatkins),
  [\#167](https://github.com/quarto-dev/quarto-r/issues/167)).

- This package now uses the x.y.z.dev versionning scheme to indicate
  development, patch, minor and major versions. This follows [Tidyverse
  package version
  conventions](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number-tidyverse).

- Adapt tests for CRAN checks issues due to Quarto v1.5.54 regression
  (though it is fixed upstream).

- Approval check in
  [`quarto_add_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_add_extension.md)
  and
  [`quarto_use_template()`](https://quarto-dev.github.io/quarto-r/reference/quarto_use_template.md)
  now works correctly (thanks, [@eveyp](https://github.com/eveyp),
  [\#172](https://github.com/quarto-dev/quarto-r/issues/172)).

## quarto 1.4

CRAN release: 2024-03-06

- This version is now adapted to Quarto 1.4 latest stable release.

- Add registration of vignette engine to use `quarto` as a vignette
  builder, and use `.qmd` file as vignette. See
  [`vignette("hello", package = "quarto")`](https://quarto-dev.github.io/quarto-r/articles/hello.md).
  (thanks, [@dcnorris](https://github.com/dcnorris),
  [\#57](https://github.com/quarto-dev/quarto-r/issues/57)).

- New
  [`quarto_binary_sitrep()`](https://quarto-dev.github.io/quarto-r/reference/quarto_binary_sitrep.md)
  checks possible difference in Quarto binary used by this package, and
  the one used by RStudio IDE (thanks,
  [@jthomasmock](https://github.com/jthomasmock),
  [\#12](https://github.com/quarto-dev/quarto-r/issues/12)).

- New
  [`is_using_quarto()`](https://quarto-dev.github.io/quarto-r/reference/is_using_quarto.md)
  to check if a directory requires using Quarto (i.e. it has a
  `_quarto.yml` or at least one `*.qmd` file) (thanks,
  [@hadley](https://github.com/hadley),
  [\#103](https://github.com/quarto-dev/quarto-r/issues/103)).

- New
  [`quarto_create_project()`](https://quarto-dev.github.io/quarto-r/reference/quarto_create_project.md)
  calls `quarto create project <type> <name>` (thanks,
  [@maelle](https://github.com/maelle),
  [\#87](https://github.com/quarto-dev/quarto-r/issues/87)).

- New
  [`quarto_add_extension()`](https://quarto-dev.github.io/quarto-r/reference/quarto_add_extension.md)
  and
  [`quarto_use_template()`](https://quarto-dev.github.io/quarto-r/reference/quarto_use_template.md)
  to deal with Quarto extensions for a Quarto project. (thanks,
  [@mcanouil](https://github.com/mcanouil),
  [\#45](https://github.com/quarto-dev/quarto-r/issues/45),
  [@remlapmot](https://github.com/remlapmot),
  [\#42](https://github.com/quarto-dev/quarto-r/issues/42)).

- [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md)
  and
  [`quarto_inspect()`](https://quarto-dev.github.io/quarto-r/reference/quarto_inspect.md)
  gains a `profile` argument (thanks,
  [@andrewheiss](https://github.com/andrewheiss),
  [\#95](https://github.com/quarto-dev/quarto-r/issues/95),
  [@salim-b](https://github.com/salim-b),
  [\#123](https://github.com/quarto-dev/quarto-r/issues/123)).

- [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md)
  gains `metadata` and `metadata_file` arguments. They can be used to
  pass modified Quarto metadata at render time. If both are set,
  `metadata` will be merged over `metadata_file` content. Internally,
  metadata will be passed as a `--metadata-file` to `quarto render`
  (thanks, [@mcanouil](https://github.com/mcanouil),
  [\#52](https://github.com/quarto-dev/quarto-r/issues/52),
  [@maelle](https://github.com/maelle),
  [\#49](https://github.com/quarto-dev/quarto-r/issues/49)).

- [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md)
  and all other relevant functions gain a `quarto_args` argument. It
  allows to pass additional options flag to `quarto` CLI. This is for
  advanced usage e.g. when new options are added to Quarto CLI that
  would not be user-facing in this package’s functions (thanks,
  [@gadenbuie](https://github.com/gadenbuie),
  [\#125](https://github.com/quarto-dev/quarto-r/issues/125)).

- Add `quiet` argument in most functions to remove warnings and
  messages. It default to `FALSE` in most function to match with
  `quarto` CLI default.

- In
  [`quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.md),
  `execute_params` now converts boolean value to `true/false` correctly
  as expected by `quarto render` (thanks,
  [@marianklose](https://github.com/marianklose),
  [\#124](https://github.com/quarto-dev/quarto-r/issues/124)).

- Error message now advises to re-run with `quiet = FALSE` because
  `quarto_render(quiet = TRUE)` will run `quarto render` in quiet mode
  (thanks to [@gadenbuie](https://github.com/gadenbuie),
  [\#126](https://github.com/quarto-dev/quarto-r/issues/126),
  [@wlandau](https://github.com/wlandau),
  [\#16](https://github.com/quarto-dev/quarto-r/issues/16)).

- **rsconnect** R package dependency has been moved to Suggest to reduce
  this package’s overall number of dependencies. **rsconnect** package
  is only required for publishing using `quarto_publish_*()` functions.
  Users will be prompted to install (when in interactive mode) if not
  installed.

- Added a `NEWS.md` file to track changes to the package.
