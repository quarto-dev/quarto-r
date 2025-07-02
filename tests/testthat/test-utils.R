test_that("has_internet works correctly", {
  skip_if_offline("example.com")
  expect_true(has_internet("https://www.example.com/"))
  expect_false(has_internet("https://www.invalid-host-that-does-not-exist.com"))
})

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

test_that("as_yaml detects NA in simple vectors", {
  expect_snapshot(
    as_yaml(list(values = c(1, NA, 3))),
    error = TRUE
  )
})

test_that("write_yaml detects NA in nested structures", {
  expect_snapshot(
    write_yaml(list(data = list(subset = c(1, NA, 3))), tempfile()),
    error = TRUE
  )
})

test_that("as_yaml shows correct NA positions", {
  expect_snapshot(
    as_yaml(list(x = c(1, NA, 3, NA))),
    error = TRUE
  )
})

test_that("as_yaml allows NaN values", {
  expect_no_error(
    as_yaml(list(values = c(1, NaN, 3)))
  )
})

test_that("write_yaml allows clean data", {
  temp_file <- tempfile()
  expect_no_error(
    quarto:::write_yaml(list(param1 = c(1, 2, 3), param2 = "test"), temp_file)
  )
  unlink(temp_file)
})

test_that("quarto_render uses write_yaml validation", {
  expect_snapshot(
    quarto_render("test.qmd", execute_params = list(bad_param = c(1, NA))),
    error = TRUE
  )
})
