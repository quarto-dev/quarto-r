test_that("Checking non interactive approval", {
  rlang::local_interactive(FALSE)
  expect_snapshot(expect_true(check_approval(TRUE, "My thing")))
  expect_snapshot(error = TRUE, {
    check_approval(FALSE, "My thing")
  })
  expect_snapshot(error = TRUE, {
    check_approval(FALSE, "My thing", see_more_at = "https://example.com")
  })
})


test_that("Checking interactive approval with prompt mocked y", {
  local_mocked_bindings(
    readline = function(...) "y"
  )
  rlang::local_interactive(TRUE)
  expect_true({
    check_approval(FALSE, "my-thing")
  })
})

test_that("Checking interactive approval with prompt mocked n", {
  local_mocked_bindings(
    readline = function(...) "n"
  )
  rlang::local_interactive(TRUE)
  expect_snapshot(expect_false({
    check_approval(FALSE, "my-thing", see_more_at = "https://example.com")
  }))
})

test_that("Checking non interactive extension approval", {
  rlang::local_interactive(FALSE)
  expect_snapshot(expect_true(check_extension_approval(TRUE, "My thing")))
  expect_snapshot(error = TRUE, {
    check_extension_approval(FALSE, "My thing")
  })
  expect_snapshot(error = TRUE, {
    check_extension_approval(
      FALSE,
      "My thing",
      see_more_at = "https://example.com"
    )
  })
})

test_that("Checking interactive extension approval with prompt mocked y", {
  local_mocked_bindings(
    readline = function(...) "y"
  )
  rlang::local_interactive(TRUE)
  expect_snapshot(expect_true({
    check_extension_approval(FALSE, "my-thing")
  }))
})

test_that("Checking interactive extension approval with prompt mocked n", {
  local_mocked_bindings(
    readline = function(...) "n"
  )
  rlang::local_interactive(TRUE)
  expect_snapshot(expect_false({
    check_extension_approval(FALSE, "my-thing")
  }))
})

test_that("Checking non interactive removal approval", {
  rlang::local_interactive(FALSE)
  expect_snapshot(expect_true(check_removal_approval(TRUE, "My thing")))
  expect_snapshot(error = TRUE, {
    check_removal_approval(FALSE, "My thing")
  })
  expect_snapshot(error = TRUE, {
    check_removal_approval(
      FALSE,
      "My thing",
      see_more_at = "https://example.com"
    )
  })
})

test_that("Checking interactive removal approval with prompt mocked y", {
  local_mocked_bindings(
    readline = function(...) "y"
  )
  rlang::local_interactive(TRUE)
  expect_snapshot(expect_true({
    check_removal_approval(FALSE, "my-thing")
  }))
})

test_that("Checking interactive removal approval with prompt mocked n", {
  local_mocked_bindings(
    readline = function(...) "n"
  )
  rlang::local_interactive(TRUE)
  expect_snapshot(expect_false({
    check_removal_approval(FALSE, "my-thing")
  }))
})
