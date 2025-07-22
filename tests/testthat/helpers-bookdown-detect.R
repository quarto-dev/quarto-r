# Create a temporary R Markdown file with test content
local_rmd_file <- function(..., .env = parent.frame()) {
  skip_if_not_installed("xfun")
  skip_if_not_installed("withr")
  # create a directory to delete for correct cleaning
  dir <- withr::local_tempdir("quarto-bookdown-test", .local_envir = .env)
  # create a file in this directory
  path <- withr::local_tempfile(
    tmpdir = dir,
    fileext = ".Rmd",
    .local_envir = .env
  )
  xfun::write_utf8(c(...), path)
  path
}

local_rmd_project <- function(files_content, .env = parent.frame()) {
  skip_if_not_installed("xfun")
  skip_if_not_installed("withr")

  # Create temporary directory
  dir <- withr::local_tempdir("bookdown-like-project", .local_envir = .env)

  # Create files in the directory
  for (i in seq_along(files_content)) {
    file_path <- file.path(dir, paste0("test", i, ".Rmd"))
    xfun::write_utf8(files_content[[i]], file_path)
  }

  dir
}

project_transform <- function(project_dir) {
  clean_paths_transform(list(
    list(actual = project_dir, replacement = "<test_dir>"),
    list(actual = escape_path(project_dir), replacement = "<test_dir>"),
    list(actual = "test1.Rmd", replacement = "<test_file1>"),
    list(actual = "test2.Rmd", replacement = "<test_file2>")
  ))
}

test_content_simple <- function() {
  c(
    "# Introduction",
    "See Figure \\@ref(fig:plot1) for details.",
    "Table \\@ref(tab:data) shows results.",
    "Equation \\@ref(eq:mean) is important.",
    "Section \\@ref(methods) explains more."
  )
}

test_content_equations <- function() {
  c(
    "# Equations",
    "The binomial probability mass function is defined as:",
    "\\begin{equation}",
    "f\\left(k\\right) = \\binom{n}{k} p^k\\left(1-p\\right)^{n-k}",
    "(\\#eq:binom)",
    "\\end{equation}",
    "See Equation \\@ref(eq:binom) for details."
  )
}

test_content_theorems <- function() {
  c(
    "# Theorems",
    "```{theorem pyth, name=\"Pythagorean theorem\"}",
    "For a right triangle, if $c$ denotes the length of the hypotenuse",
    "and $a$ and $b$ denote the lengths of the other two sides, we have",
    "",
    "$$a^2 + b^2 = c^2$$",
    "```",
    "```{lemma label=\"important\", name=\"Helper Lemma\"}",
    "This is a lemma with explicit label.",
    "```",
    "::: {.theorem #pyth-new name=\"Pythagorean theorem\"}",
    "For a right triangle, if $c$ denotes the length of the hypotenuse",
    "and $a$ and $b$ denote the lengths of the other two sides, we have",
    "",
    "$$a^2 + b^2 = c^2$$",
    ":::",
    "See Theorem \\@ref(thm:pyth) for the old syntax proof.",
    "See Lemma \\@ref(lem:important) for the lemma.",
    "See Theorem \\@ref(thm:pyth-new) for the new syntax proof."
  )
}

test_content_unsupported <- function() {
  c(
    "# Unsupported Types",
    "See Conjecture \\@ref(cnj:guess) for hypothesis.",
    "Also Hypothesis \\@ref(hyp:assumption) is relevant."
  )
}

test_content_empty <- function() {
  c(
    "# Empty Document",
    "This document has no cross-references.",
    "Just regular text content."
  )
}
