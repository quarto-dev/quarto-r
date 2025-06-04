# quarto (development version)

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

- `QUARTO_R_QUIET` environment variable can be used to set `quarto.quiet` option, which overrides any `quiet = TRUE` argument passed to `quarto_*` functions. This can be useful to debug Quarto rendering inside other packages, like **pkgdown**. Overrides will also now happens for [GHA debug logging](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/troubleshooting-workflows/enabling-debug-logging).

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
