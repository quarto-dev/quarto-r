# quarto (development version)

- Added `project_path()`, `get_running_project_root()`, and `find_project_root()` functions for Quarto-aware project path construction. These functions provide a consistent way to reference files relative to the project root, working both during Quarto rendering (using `QUARTO_PROJECT_ROOT` environment variables) and in interactive sessions (using intelligent project detection). The `project_path()` function is particularly useful in Quarto document cells where you need to reference data files or scripts from the project root regardless of the document's location in subdirectories (#180).

- `quarto_preview()` now explicitly returns the preview server URL (invisibly) and documents this behavior. This enables programmatic workflows such as taking screenshots with **webshot2** or passing the URL to other automation tools (thanks, @cwickham, #233).

- Added NA value detection in YAML processing to prevent silent failures when passing R's `NA` values to Quarto CLI. Functions `as_yaml()` and `write_yaml()` now validate for NA values and provide clear error messages with actionable suggestions. This addresses issues where R's `NA` values get converted to YAML strings (like `.na.real`) that Quarto doesn't recognize as missing values, because they are not supported in YAML 1.2 spec. This is to help users handle missing data appropriately before passing to Quarto (#168).

- Added `qmd_to_r_script()` function to extract R code cells from Quarto documents and create R scripts. This experimental function preserves chunk options using `#|` syntax, adds YAML metadata as spin-style headers, and handles mixed-language documents by filtering only R cells. Complements the existing `add_spin_preamble()` function for working with R scripts in Quarto workflows (#208, quarto-dev/quarto-cli#9112).

- Added `add_spin_preamble()` function to add YAML preambles to R scripts for use with Quarto Script rendering support. The function automatically detects existing preambles and provides flexible customization options through `title` and `preamble` parameters (#164).

- `quarto_create_project()` gains a `title` argument to set the project title independently from the directory name. This allows creating projects with custom titles, including when using `name = "."` to create a project in the current directory (thanks, @davidkane9, #148). This matches with `--title` addition for `quarto create project` in Quarto CLI v1.5.15.

- `quarto_use_template()` now supports using templates in another empty directory via the `dir` argument. However, the function will fail with a clear error message when used in non-empty directories, as interactive prompting is required and handled by Quarto CLI directly (requires Quarto 1.5.15+). Follow for [quarto-dev/quarto-cli#11127](https://github.com/quarto-dev/quarto-cli/issues/11127) for change with `--no-prompt` behavior in future Quarto versions.

- `quarto_render(output_file = )` now sets the `output-file` Quarto metadata instead of the `--output` CLI flag. This allows the output file information to correctly be processed by Quarto, as if passed in a YAML header. e.g. it allows to support multiple output formats in the same render call. `quarto_render(quarto_args = c('--output', 'dummy.html'))` can still be used to set the `--output` CLI flag to enforce using the CLI flag and not the metadata processed by Quarto (#251, #43).

- Added `check_newer_version()` function to check if a newer version of Quarto is available. The function compares the current Quarto version against the latest stable and prerelease versions. It is aimed for verbosity by default (`verbose = TRUE`), but `verbose = FALSE` can also be set for just checking update availability with TRUE or FALSE return values. Version information is cached per session for up to 24 hours to minimize network requests.

- Added `write_yaml_metadata_block()` function to dynamically set YAML metadata in Quarto documents from R code chunks. This addresses the limitation where Quarto metadata must be static and defined in the document header. The function enables conditional content and metadata-driven document behavior based on R computations (thanks, @kmasiello, #137, #160).

- Added debugging logic for quarto vignette engine to help diagnose issues with Quarto vignettes in **pkgdown** and other context (thanks, @hadley, #185).
  Set `quarto.log.debug = TRUE` to enable debugging messages (or `R_QUARTO_LOG_DEBUG = TRUE` environment variable). 
  Set `quarto.log.file` to change the file path to write to (or `R_QUARTO_LOG_FILE` environment variable). Default will be `./quarto-r-debug.log`
  Debug mode will be on automatically when debugging Github Actions workflows, or when Quarto CLI's environment variable `QUARTO_LOG_LEVEL` is set to `DEBUG`.

- Added a `new_blog_post()` function (thanks, @topeto, #22). 

- Make `quarto_render(as_job = TRUE)` wrapable (thanks, @salim-b, #105).

- Quarto CLI will now correctly use the same R version than the one used to run functions in this package (#204).

- Add `quarto_available()` function to check if Quarto CLI is found (thanks, @hadley, #187).

- `quarto_render()` now correctly set `as_job` when not inside RStudio IDE and required **rstudioapi** functions are not available (#203).

- Add several new wrapper function (thanks, @parmsam, #192): 
  - `quarto_list_extensions()` to list installed extensions using `quarto list extensions`
  - `quarto_remove_extension()` to remove an installed extension using `quarto remove extensions`
  - `quarto_update_extension()` to update an installed extension using `quarto update extensions`

- `quarto_create_project()` offers better user experience now (thanks, @jennybc, #206, #153).

- `quarto_preview()` gains a `quiet` argument to suppress any output from R or Quarto CLI (thanks, @cwickham, #232.)

- Add some helpers function `theme_brand_*` and `theme_colors_*` to help theme with dark and light brand using some common graph and table packages (thanks,  @gordonwoodhull, [#234](https://github.com/quarto-dev/quarto-r/issues/234)).

- Add `quarto.quiet` options to allow more verbose error message when `quarto_*` function are used inside other package. 
  For example, inside **pkgdown** for building Quarto vignettes. **pkgdown** sets `quiet = TRUE` internally for its call to `quarto_render()`, 
  and setting `options(quarto.quiet = TRUE)` allows to overwrite this.
  
- `quarto_path()` now returns a normalized path with potential symlink resolved, for less confusion with `quarto_binary_sitrep()` (thanks, @jennybc).

- Fix an error with interactive prompt for extension approval (thanks, @wjschne, #212).

- `quarto_path()` now correctly return `NULL` when no quarto is found in the PATH (thanks, @jeroen, #220, #221).

- `R_QUARTO_QUIET` environment variable can be used to set `quarto.quiet` option, which overrides any `quiet = TRUE` argument passed to `quarto_*` functions. This can be useful to debug Quarto rendering inside other packages, like **pkgdown**. Overrides will also now happens for [GHA debug logging](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/troubleshooting-workflows/enabling-debug-logging).

- Correctly report Quarto CLI error when background process call to `quarto` fails (thanks, @salim-b, [#235](https://github.com/quarto-dev/quarto-r/issues/235))

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
