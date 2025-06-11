test_that("append to existing", {
  expect_identical(append_cli_args("a"), "a")
  expect_identical(append_cli_args(c("a", "b")), c("a", "b"))
  expect_identical(append_cli_args("c", c("a", "b")), c("a", "b", "c"))
  expect_identical(append_cli_args("b", c("a", "c"), 1), c("a", "b", "c"))
  expect_identical(
    append_cli_args(c("b", "c"), c("a", "d"), 1),
    c("a", "b", "c", "d")
  )
})

test_that("create profile arg", {
  expect_identical(cli_arg_profile("a"), c("--profile", "a"))
  expect_identical(cli_arg_profile(c("a", "b")), c("--profile", "a,b"))
  expect_identical(
    cli_arg_profile(c("a", "b"), "input.qmd"),
    c("input.qmd", "--profile", "a,b")
  )
})

test_that("create quiete arg", {
  expect_identical(cli_arg_quiet(), c("--quiet"))
  expect_identical(cli_arg_quiet("input.qmd"), c("input.qmd", "--quiet"))
})

test_that("quarto.quiet options takes over", {
  expect_identical(is_quiet(TRUE), TRUE)
  expect_identical(is_quiet(FALSE), FALSE)
  expect_identical(is_quiet(NA), FALSE)
  withr::with_options(list(quarto.quiet = TRUE), {
    expect_identical(is_quiet(TRUE), TRUE)
    expect_identical(is_quiet(FALSE), TRUE)
    expect_identical(is_quiet(NA), TRUE)
  })
  withr::with_options(list(quarto.quiet = FALSE), {
    expect_identical(is_quiet(TRUE), FALSE)
    expect_identical(is_quiet(FALSE), FALSE)
    expect_identical(is_quiet(NA), FALSE)
  })
})

test_that("R_QUARTO_QUIET options takes over", {
  withr::with_envvar(list(R_QUARTO_QUIET = TRUE), {
    expect_identical(is_quiet(TRUE), TRUE)
    expect_identical(is_quiet(FALSE), TRUE)
    expect_identical(is_quiet(NA), TRUE)
  })
  withr::with_envvar(list(R_QUARTO_QUIET = FALSE), {
    expect_identical(is_quiet(TRUE), FALSE)
    expect_identical(is_quiet(FALSE), FALSE)
    expect_identical(is_quiet(NA), FALSE)
  })
  withr::with_envvar(list(R_QUARTO_QUIET = "true"), {
    expect_identical(is_quiet(TRUE), TRUE)
    expect_identical(is_quiet(FALSE), TRUE)
    expect_identical(is_quiet(NA), TRUE)
  })
  withr::with_envvar(list(R_QUARTO_QUIET = "false"), {
    expect_identical(is_quiet(TRUE), FALSE)
    expect_identical(is_quiet(FALSE), FALSE)
    expect_identical(is_quiet(NA), FALSE)
  })
})

test_that("quarto.quiet options takes over R_QUARTO_QUIET", {
  withr::with_options(list(quarto.quiet = TRUE), {
    withr::with_envvar(list(R_QUARTO_QUIET = FALSE), {
      expect_identical(is_quiet(TRUE), TRUE)
      expect_identical(is_quiet(FALSE), TRUE)
      expect_identical(is_quiet(NA), TRUE)
    })
    withr::with_envvar(list(R_QUARTO_QUIET = TRUE), {
      expect_identical(is_quiet(TRUE), TRUE)
      expect_identical(is_quiet(FALSE), TRUE)
      expect_identical(is_quiet(NA), TRUE)
    })
  })
  withr::with_options(list(quarto.quiet = FALSE), {
    withr::with_envvar(list(R_QUARTO_QUIET = TRUE), {
      expect_identical(is_quiet(TRUE), FALSE)
      expect_identical(is_quiet(FALSE), FALSE)
      expect_identical(is_quiet(NA), FALSE)
    })
    withr::with_envvar(list(R_QUARTO_QUIET = FALSE), {
      expect_identical(is_quiet(TRUE), FALSE)
      expect_identical(is_quiet(FALSE), FALSE)
      expect_identical(is_quiet(NA), FALSE)
    })
  })
})
