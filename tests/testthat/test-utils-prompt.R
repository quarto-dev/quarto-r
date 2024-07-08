test_that("Checking extension with approval prompt mocked y", {
  local_mocked_bindings(
    readline = function(...) "y",
    is_interactive = function() TRUE
  )
  expect_true({
    check_extension_approval(FALSE, "Quarto extensions", "https://quarto.org/docs/extensions/managing.html")
  })
})

test_that("Checking extension with approval prompt mocked n", {
  local_mocked_bindings(
    readline = function(...) "n",
    is_interactive = function() TRUE
  )
  expect_false({
    check_extension_approval(FALSE, "Quarto extensions", "https://quarto.org/docs/extensions/managing.html")
  })
})

test_that("Checking extension approval", {
  skip_if_no_quarto()
  skip_if_offline("github.com")

  expect_true(check_extension_approval(TRUE, "Quarto extensions", "https://quarto.org/docs/extensions/managing.html"))
  expect_true(check_extension_approval(TRUE, "Quarto templates", "https://quarto.org/docs/extensions/formats.html#distributing-formats"))

  expect_error({
    local_reproducible_output(rlang_interactive = FALSE)
    check_extension_approval(FALSE, "Quarto extensions", "https://quarto.org/docs/extensions/managing.html")
  })
  expect_error({
    local_reproducible_output(rlang_interactive = FALSE)
    check_extension_approval(TRUE, "Quarto extensions", "https://quarto.org/docs/extensions/managing.html")
  })
})
