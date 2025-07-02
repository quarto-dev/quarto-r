test_that("check_params_for_na allows clean parameters", {
  # Should pass without error
  good_params <- list(
    a = 1:5,
    b = c("hello", "world"),
    nested = list(x = 10, y = 20)
  )

  expect_silent(check_params_for_na(good_params))
})

test_that("check_params_for_na detects NA in simple vectors", {
  bad_params <- list(values = c(1, NA, 3))

  expect_snapshot(
    error = TRUE,
    check_params_for_na(bad_params),
  )
})

test_that("check_params_for_na detects NA in nested structures", {
  nested_params <- list(
    data = list(
      subset = c(1, NA, 3)
    )
  )

  expect_snapshot(
    error = TRUE,
    check_params_for_na(nested_params),
  )
})

test_that("check_params_for_na shows correct NA positions", {
  multi_na_params <- list(x = c(1, NA, 3, NA, 5))

  expect_snapshot(
    error = TRUE,
    check_params_for_na(multi_na_params),
  )
})

test_that("check_params_for_na handles different NA types", {
  # Test different NA types
  expect_error(
    check_params_for_na(list(x = NA_real_)),
    "NA.*values detected"
  )

  expect_error(
    check_params_for_na(list(x = NA_integer_)),
    "NA.*values detected"
  )

  expect_error(
    check_params_for_na(list(x = NA_character_)),
    "NA.*values detected"
  )

  expect_error(
    check_params_for_na(list(x = c(TRUE, NA))),
    "NA.*values detected"
  )
})
