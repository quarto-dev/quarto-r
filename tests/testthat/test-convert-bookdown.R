test_that("detect_bookdown_crossrefs works with valid single file", {
  # Create temporary file using local helper
  test_file <- local_rmd_file(test_content_simple())

  # Test function works
  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  expect_type(result, "list")
  expect_length(result, 4)
  for (item in result) {
    expect_true(all(
      c("file", "line", "bookdown_syntax", "quarto_syntax", "type") %in%
        names(item)
    ))
  }
})

test_that("detect_bookdown_crossrefs works with valid directory", {
  test_dir <- local_rmd_project(list(
    test_content_simple(),
    test_content_equations()
  ))

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_dir, verbose = FALSE),
    transform = project_transform(test_dir)
  )

  expect_type(result, "list")
  expect_gt(length(result), 0)

  files_found <- unique(sapply(result, function(x) x$file))
  expect_length(files_found, 2)
})

test_that("detect_bookdown_crossrefs handles invalid inputs gracefully", {
  expect_snapshot(
    result1 <- detect_bookdown_crossrefs("nonexistent/path")
  )
  expect_null(result1)

  txt_file <- withr::local_tempfile(fileext = ".txt")
  xfun::write_utf8("some text", txt_file)
  expect_snapshot(
    result2 <- detect_bookdown_crossrefs(txt_file),
    transform = single_file_transform(txt_file)
  )
  expect_null(result2)

  empty_dir <- withr::local_tempdir("empty-test")
  expect_snapshot(
    result3 <- detect_bookdown_crossrefs(empty_dir),
    transform = clean_paths_transform(list(
      list(actual = empty_dir, replacement = "<empty_dir>")
    ))
  )
  expect_null(result3)
})

test_that("detect_bookdown_crossrefs verbose parameter works", {
  test_file <- local_rmd_file(test_content_simple())

  expect_snapshot(
    result_compact <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  expect_snapshot(
    result_verbose <- detect_bookdown_crossrefs(test_file, verbose = TRUE),
    transform = single_file_transform(test_file)
  )
  # both result objects should be identical only printing should differ
  expect_identical(result_compact, result_verbose)
})

test_that("detect_bookdown_crossrefs returns NULL when no cross-references found", {
  test_file <- local_rmd_file(test_content_empty())

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )
  expect_null(result)
})

test_that("detects figure cross-references correctly", {
  test_file <- local_rmd_file(
    "# Test Document",
    "See Figure \\@ref(fig:plot1) for details."
  )

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true("fig" %in% types_found)

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = TRUE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true("fig" %in% types_found)
})

test_that("detects table cross-references correctly", {
  test_file <- local_rmd_file(
    "# Test Document",
    "Table \\@ref(tab:data) shows results."
  )

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true("tab" %in% types_found)

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = TRUE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true("tab" %in% types_found)
})

test_that("detects numbered equations correctly", {
  test_file <- local_rmd_file(
    "# Test Document",
    "\\begin{equation}",
    "f\\left(k\\right) = \\binom{n}{k} p^k\\left(1-p\\right)^{n-k}",
    "(\\#eq:binom)",
    "\\end{equation}"
  )

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true("numbered_equation" %in% types_found)

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = TRUE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true("numbered_equation" %in% types_found)
})

test_that("detects unsupported cross-references correctly", {
  test_file <- local_rmd_file(
    "# Test Document",
    "See Conjecture \\@ref(cnj:guess) for hypothesis."
  )

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true("cnj_unsupported" %in% types_found)

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = TRUE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true("cnj_unsupported" %in% types_found)
})

test_that("detects theorem block with label correctly", {
  test_file <- local_rmd_file(
    "# Test Document",
    "```{lemma label=\"important\", name=\"Helper Lemma\"}",
    "This is a lemma with explicit label.",
    "```",
    "See Lemma \\@ref(lem:important) for the lemma."
  )

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true(any(grepl("lemma_block_labeled", types_found)))
  expect_true("lem" %in% types_found)

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = TRUE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true(any(grepl("lemma_block_labeled", types_found)))
  expect_true("lem" %in% types_found)
})

test_that("detects theorem block without label correctly", {
  test_file <- local_rmd_file(
    "# Test Document",
    "```{theorem name=\"Pythagorean theorem\"}",
    "For a right triangle, if $c$ denotes the length of the hypotenuse",
    "and $a$ and $b$ denote the lengths of the other two sides, we have",
    "$$a^2 + b^2 = c^2$$",
    "```",
    "See Theorem for the proof."
  )

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_identical(types_found, "theorem_block_unlabeled")

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = TRUE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_identical(types_found, "theorem_block_unlabeled")
})

test_that("detects theorem div syntax correctly", {
  test_file <- local_rmd_file(
    "# Test Document",
    "::: {.theorem #pyth-new name=\"Pythagorean theorem\"}",
    "For a right triangle, if $c$ denotes the length of the hypotenuse",
    "and $a$ and $b$ denote the lengths of the other two sides, we have",
    "$$a^2 + b^2 = c^2$$",
    ":::",
    "See Theorem \\@ref(thm:pyth-new) for the proof."
  )

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = FALSE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true(any(grepl("theorem_div", types_found)))
  expect_true("thm" %in% types_found)

  expect_snapshot(
    result <- detect_bookdown_crossrefs(test_file, verbose = TRUE),
    transform = single_file_transform(test_file)
  )

  types_found <- unique(sapply(result, function(x) x$type))
  expect_true(any(grepl("theorem_div", types_found)))
  expect_true("thm" %in% types_found)
})
