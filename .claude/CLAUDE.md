# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this package is

`quarto` = R package wrapping the [Quarto CLI](https://quarto.org). Lets R users render, preview, publish, inspect, create, and extend Quarto projects from R. Not required to use Quarto with R — convenience layer for scripting Quarto from R.

Quarto CLI is runtime dep declared in `SystemRequirements`. Most non-trivial behavior shells out to `quarto` binary via `processx::run()`. Code touching binary must tolerate Quarto missing (use `quarto_path()` / `find_quarto()` / `quarto_available()`); tests must skip when absent (see Testing).

## Common commands

Run via `Rscript -e "<expr>"` or inside an interactive R session. Multi-version users can swap `Rscript` for `rig run` ([r-lib/rig](https://github.com/r-lib/rig)).

```r
# Document (regenerate NAMESPACE + man/ from roxygen)
devtools::document()

# Run all tests
devtools::test()

# Run tests in a single file by filter
devtools::test(filter = "render")

# Run a single test_that() block by name
testthat::test_file("tests/testthat/test-render.R", desc = "partial name")

# Full R CMD check (what CI runs, minus matrix)
devtools::check()

# Install dev version locally
devtools::install()

# Build pkgdown site locally
pkgdown::build_site()

# Accept snapshot changes after deliberate, reviewed output change
testthat::snapshot_accept()
```

Formatter: `air.toml` configures [Air](https://posit-dev.github.io/air/) — 80 cols, 2-space indent, `_snaps` excluded. Run `air format .` if Air installed; otherwise leave formatting alone.

## Testing model — read before editing tests

testthat edition 3. Heavy snapshot use. Tests lean on real Quarto CLI. `tests/testthat/helpers.R` defines shared scaffolding — reuse it.

- **`skip_if_no_quarto(ver = NULL)` / `skip_if_quarto(ver)` / `skip_if_quarto_between(min, max)`** — every test calling a function shelling out to `quarto` must start with one. CI runs matrix including "no Quarto" cell; un-skipped tests break it.
- **`local_qmd_file(...)` / `local_quarto_project(name, type, ...)`** — temp `.qmd` / temp Quarto projects with `withr` cleanup. Use instead of writing to repo tree.
- **`.render()` / `.render_and_read()` / `expect_snapshot_qmd_output()`** — drive `quarto_render()`, capture output, snapshot. Snapshots pinning rendered HTML/PDF/etc. live under `tests/testthat/_snaps/` with `.test.out` extension.
- **`transform_quarto_cli_in_output(full_path, version, dir_only, hide_stack)`** — snapshot transformer scrubbing absolute Quarto paths, version strings, stack traces, and `quarto.exe` vs `quarto` differences across platforms. Snapshots of Quarto CLI output must pass an appropriate transform; otherwise they churn across machines and Quarto versions.
- **`clean_paths_transform()` / `single_file_transform()`** — hide tempdir paths in snapshots.
- **`local_clean_state()`** — clears env vars (`QUARTO_PATH`, `R_QUARTO_LOG_DEBUG`, `R_QUARTO_LOG_FILE`, `QUARTO_LOG_LEVEL`, `ACTIONS_RUNNER_DEBUG`, `ACTIONS_STEP_DEBUG`) + `quarto.*` options. Use when test mutates env/options.
- **`install_dev_package()` / `quick_install()`** — install dev pkg into temp libpath for tests needing child R sessions (e.g. vignette engine). Triggers outside `R CMD check`.

`*.new.md` or `*.new.test.out` next to a snapshot = snapshot diff. Review, then fix the code or call `testthat::snapshot_accept()` if new output is correct. `_snaps/` excluded from Air and from R build.

## Architecture (big picture)

Thin scripting layer. Almost every public function maps to a Quarto CLI subcommand or a small Quarto-aware R helper.

**Binary discovery.** `R/quarto.R` owns `quarto_path()` (respects `QUARTO_PATH`, falls back to `Sys.which()`), `find_quarto()` (aborts if missing), `quarto_version()` / `quarto_available()`. Anything shelling out goes through this layer — no direct `Sys.which("quarto")` elsewhere.

**Subprocess execution.** `processx::run()` (and `processx::process()` for the long-running preview daemon) invokes the binary. `R/quarto-args.R` builds CLI argument vectors. `R/r-logging.R` wires logging env vars (`R_QUARTO_LOG_*`, `QUARTO_LOG_LEVEL`) for verbosity. R library path passed to subprocess as `R_LIBS` so the child resolves packages from the same place as the parent.

**Public surface, by file:**
- `R/render.R` — `quarto_render()`: main entry point, wraps `quarto render`.
- `R/preview.R` + `R/daemon.R` — `quarto_preview()` / `quarto_preview_stop()` / `quarto_serve()`: long-running preview server via daemon stored in pkg state.
- `R/publish.R` — `quarto_publish_doc()` / `quarto_publish_site()` / `quarto_publish_app()`.
- `R/inspect.R` — `quarto_inspect()`: parsed JSON from `quarto inspect`.
- `R/create.R` + `R/use.R` — `quarto_create_project()`, `quarto_use_template()`.
- `R/add.R` / `R/remove.R` / `R/update.R` / `R/list.R` — extension mgmt (`quarto add/remove/update/list`).
- `R/blog.R` — `new_blog_post()` for blog scaffolding.
- `R/theme.R` — `theme_brand_*()` / `theme_colors_*()` adapters from Quarto/brand YAML to ggplot2, gt, flextable, plotly, thematic.
- `R/table-helper.R` — `tbl_qmd_div*()` / `tbl_qmd_span*()` emit Quarto HTML inside R tables.
- `R/parameters.R`, `R/metadata.R` — parameterized doc helpers (`has_parameters()`, `write_yaml_metadata_block()`, etc.).
- `R/spin.R` — `add_spin_preamble()` / `qmd_to_r_script()` for `.R` ↔ `.qmd` conversion (knitr::spin-style).
- `R/convert-bookdown.R` — bookdown → Quarto helpers; `detect_bookdown_crossrefs()`.
- `R/utils-projects.R` — `find_project_root()`, `get_running_project_root()`, `project_path()`, `is_using_quarto()`.
- `R/utils-versions.R` — `check_newer_version()` + semver comparison helpers.
- `R/utils-vignettes.R` + `R/zzz.R` — `.onLoad()` registers Quarto vignette engine (`VignetteBuilder: quarto` in DESCRIPTION); engine builds pkg's own vignettes via Quarto.
- `R/utils-extract.R` — purl / chunk-extraction utilities.
- `R/utils-prompt.R` — interactive prompts (gated by `rlang::is_interactive()`).
- `R/backports.R` — small shims; keep new code on modern equivalents, leave file for genuine R-version backports.
- `R/aaa.R` — package-level helpers loaded first (utility infra, not user-visible).

**Cross-cutting conventions:**
- User-facing messages, warnings, errors go through `cli::cli_abort()` / `cli::cli_inform()`. Use `{}` for substitution but escape literal `{` / `}` (see commit `630ca2d`). No base `stop()` / `message()`.
- Path normalization via `xfun::normalize_path()` for cross-platform consistency, not `normalizePath()`. Snapshot transforms rely on this.
- Package writes options under `quarto.*` (e.g. `quarto.echo_cmd`, `quarto.log.debug`, `quarto.log.file`) + env vars under `R_QUARTO_*` / `QUARTO_*`. New option/env var follow that prefix.
- R version floor: `R >= 4.1.0` (DESCRIPTION). `|>` and `\(x)` fine; don't add features needing newer R without bumping floor deliberately.

## CI matrix (what "passing" means)

`.github/workflows/R-CMD-check.yaml` runs `R CMD check --as-cran --no-manual` on macOS / Windows / Ubuntu against R `release`, `devel`, `oldrel-1..4`, plus an `r: '4.1'` Windows cell (Rtools40 compiler). Three Quarto configs per platform: `release`, `pre-release`, **no Quarto** (`--ignore-vignettes`, `--no-build-vignettes`). When changing tests, check all three mentally — anything calling `quarto` must `skip_if_no_quarto()`; snapshots must stay stable across Quarto release vs. pre-release (use `transform_quarto_cli_in_output(version = TRUE)` if version strings leak).

Other workflows: `pkgdown.yaml` (docs), `pr-commands.yaml` (`/document`, `/style`), `rhub.yaml`, `test-coverage.yaml` (codecov).

## Repo notes

- CRAN package (`quarto` on CRAN). CRAN policy applies for any new dep, file write outside tempdir, or example running without `\dontrun{}` / `\donttest{}`.
- `air.toml` = source of truth for formatting. No hand reformat. No `_snaps/` reformat.
