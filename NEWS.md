# quarto (development version)

- Add `quiet` argument to pass `--quiet` to `quarto` CLI commands

- Error message now advises to re-run with `quiet = FALSE` because `quarto_render(quiet = TRUE)` will run `quarto render` in quiet mode (thanks to @gadenbuie, #126, @wlandau, #16).

- **rsconnect** R package dependency has been moved to Suggest to reduce this package's overall number of dependencies. **rsconnect** package is only required for publishing using `quarto_publish_*()` functions. Users will be prompted to install (when in interactive mode) if not installed.

- Add `quarto_add_extension()` and `quarto_use_template()` to deal with Quarto extensions for a Quarto project. (thanks, @mcanouil, #45, @remlapmot, #42).

- Add `profile` arguments to `quarto_render()` and `quarto_inspect()` (thanks, #95, @andrewheiss, #123, @salim-b).

- Add `metadata` and `metadata_file` to `quarto_render()` to pass modify Quarto metadata from calling render. If both are set, `metadata` will be merged over `metadata_file` content. Internally, metadata will be passed as a `--metadata-file` to `quarto render` (thanks, @mcanouil, #52, @maelle, #49).

- Added a `NEWS.md` file to track changes to the package.

- `execute_params` in `quarto_render()` now converts boolean value to `true/false` correctly as expected by `quarto render` (thanks, @marianklose, #124).
