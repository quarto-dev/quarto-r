test_that("append to existing", {
  expect_identical(append_cli_args("a"), "a")
  expect_identical(append_cli_args(c("a", "b")), c("a", "b"))
  expect_identical(append_cli_args("c", c("a", "b")), c("a", "b", "c"))
  expect_identical(append_cli_args("b", c("a", "c"), 1), c("a", "b", "c"))
  expect_identical(append_cli_args(c("b","c"), c("a", "d"), 1), c("a", "b", "c", "d"))
})

test_that("create profile arg", {
  expect_identical(cli_arg_profile("a"), c("--profile", "a"))
  expect_identical(cli_arg_profile(c("a", "b")), c("--profile", "a,b"))
  expect_identical(cli_arg_profile(c("a", "b"), "input.qmd"), c("input.qmd", "--profile", "a,b"))
})
