# quarto (development version)

* Add `metadata` and `metadata_file` to `quarto_render()` to pass modify Quarto metadata from calling render. If both are set, `metadata` will be merged over `metadata_file` content. Internally, metadata will be passed as a `--metadata-file` to `quarto render` (thanks, @mcanouil, #52, @maelle, #49).

* Added a `NEWS.md` file to track changes to the package.

* `execute_params` in `quarto_render()` now converts boolean value to `true/false` correctly as expected by `quarto render` (thanks, @marianklose, #124).
