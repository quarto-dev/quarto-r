# Integration test for the actual motivation behind switching to
# --metadata-file in PR #52: top-level (non-format-nested) keys from
# _quarto.yml can be overridden, which --metadata key:value cannot do
# (--metadata only reaches keys under the chosen output format).
# Format-nested keys (e.g. format.html.toc-title) are consumed by
# Quarto before reaching Pandoc, so they do not appear in native AST;
# a top-level key is the right surface to demonstrate the override.
# A Lua filter scrubs all metadata except an allowlist so the
# native-AST snapshot stays small and stable across Quarto versions.

test_that("metadata overrides keys from _quarto.yml", {
  skip_if_no_quarto()
  skip_if_not_installed("withr")
  skip_if_not_installed("xfun")

  proj <- withr::local_tempdir("quarto-metadata-nested-")

  xfun::write_utf8(
    c(
      "project:",
      "  type: default",
      "format:",
      "  html:",
      "    toc-title: Original",
      "custom-key: from-quarto-yml"
    ),
    file.path(proj, "_quarto.yml")
  )

  xfun::write_utf8(
    c(
      "---",
      "title: Doc",
      "---",
      "",
      "body"
    ),
    file.path(proj, "index.qmd")
  )

  # Lua filter: keep only allowlisted meta keys, drop document body.
  # Result is a tiny, deterministic native AST regardless of what else
  # Quarto injects (engines, extension paths, etc.).
  xfun::write_utf8(
    c(
      'function Pandoc(doc)',
      '  local wanted = { ["title"] = true, ["custom-key"] = true }',
      '  local kept = pandoc.Meta({})',
      '  for k, v in pairs(doc.meta) do',
      '    if wanted[k] then kept[k] = v end',
      '  end',
      '  return pandoc.Pandoc({}, kept)',
      'end'
    ),
    file.path(proj, "extract-meta.lua")
  )

  withr::local_dir(proj)

  quarto_render(
    "index.qmd",
    output_format = "native",
    metadata = list(`custom-key` = "overridden"),
    quarto_args = c("--lua-filter", "extract-meta.lua"),
    quiet = TRUE
  )

  announce_snapshot_file(name = "metadata-toplevel-override.test.out")
  expect_snapshot_file(
    file.path(proj, "index.native"),
    "metadata-toplevel-override.test.out"
  )
})
