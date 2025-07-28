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
  skip_on_cran() # Skip on CRAN as we current throw warning only on CRAN
  bad_params <- list(values = c(1, NA, 3))

  expect_snapshot(
    error = TRUE,
    check_params_for_na(bad_params),
  )
})

test_that("check_params_for_na detects NA in nested structures", {
  skip_on_cran() # Skip on CRAN as we current throw warning only on CRAN
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
  skip_on_cran() # Skip on CRAN as we current throw warning only on CRAN
  multi_na_params <- list(x = c(1, NA, 3, NA, 5))

  expect_snapshot(
    error = TRUE,
    check_params_for_na(multi_na_params),
  )
})

test_that("check_params_for_na handles different NA types", {
  skip_on_cran() # Skip on CRAN as we current throw warning only on CRAN
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
  skip_on_cran() # Skip on CRAN as we current throw warning only on CRAN
  expect_snapshot(
    error = TRUE,
    as_yaml(list(values = c(1, NA, 3)))
  )
})

test_that("write_yaml detects NA in nested structures", {
  skip_on_cran() # Skip on CRAN as we current throw warning only on CRAN
  expect_snapshot(
    error = TRUE?write_yaml(list(data = list(subset = c(1, NA, 3))), tempfile())
  )
})

test_that("as_yaml shows correct NA positions", {
  skip_on_cran() # Skip on CRAN as we current throw warning only on CRAN
  expect_snapshot(
    error = TRUE,
    as_yaml(list(x = c(1, NA, 3, NA)))
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
  skip_on_cran() # Skip on CRAN as we current throw warning only on CRAN
  expect_snapshot(
    error = TRUE,
    quarto_render("test.qmd", execute_params = list(bad_param = c(1, NA)))
  )
})


test_that("yaml_quote_string adds quoted attribute to strings", {
  # Single string
  result <- yaml_quote_string("1.0")
  expect_true(attr(result, "quoted"))
  expect_equal(as.character(result), "1.0")

  # Multiple strings
  multi_result <- yaml_quote_string(c("1.0", "2.0"))
  expect_length(multi_result, 2)
  expect_true(attr(multi_result[[1]], "quoted"))
  expect_true(attr(multi_result[[2]], "quoted"))
})

test_that("yaml_quote_string only works with character vectors", {
  expect_error(
    yaml_quote_string(123),
    "yaml_quote_string() only works with character vectors",
    fixed = TRUE
  )

  expect_error(
    yaml_quote_string(c(1, 2, 3)),
    "yaml_quote_string() only works with character vectors",
    fixed = TRUE
  )
})

test_that("yaml_character_handler quotes invalid octal strings only", {
  invalid_octals <- c("029", "089", "099", "0189")
  for (case in invalid_octals) {
    expect_true(
      attr(yaml_character_handler(!!case), "quoted"),
    )
  }
})

test_that("yaml_character_handler doesn't quote valid octals or regular strings", {
  not_quoted_cases <- c("0123", "007", "0567", "0", "123", "hello", "abc123")

  for (case in not_quoted_cases) {
    expect_null(
      attr(yaml_character_handler(!!case), "quoted"),
    )
  }
})

test_that("yaml_character_handler preserves user-set quoted attribute", {
  x <- "hello"
  attr(x, "quoted") <- TRUE

  result <- yaml_character_handler(x)
  expect_true(attr(result, "quoted"))
  expect_equal(as.character(result), "hello")
})

test_that("yaml_character_handler handles character vectors", {
  result <- yaml_character_handler(c("029", "0123", "089", "hello"))

  expect_length(result, 4)
  expect_true(attr(result[[1]], "quoted"))
  expect_null(attr(result[[2]], "quoted"))
  expect_true(attr(result[[3]], "quoted"))
  expect_null(attr(result[[4]], "quoted"))
})

test_that("yaml_character_handler handles edge cases", {
  edge_cases <- c(NA_character_, "", "0")
  result <- yaml_character_handler(edge_cases)
  expect_null(attr(result[[1]], "quoted"))
  expect_null(attr(result[[2]], "quoted"))
  expect_null(attr(result[[3]], "quoted"))
})

test_that("as_yaml quotes invalid octals but lets yaml package handle valid ones", {
  expect_identical(as_yaml(list(x = "029")), "x: \"029\"\n")
  expect_identical(as_yaml(list(x = "089")), "x: \"089\"\n")
  expect_identical(as_yaml(list(x = "0123")), "x: '0123'\n")
  expect_identical(as_yaml(list(x = "007")), "x: '007'\n")
  expect_identical(as_yaml(list(x = "hello")), "x: hello\n")
})

test_that("as_yaml preserves user control with yaml_quote_string", {
  result <- as_yaml(list(
    version = yaml_quote_string("1.0"),
    auto_quoted = "029",
    normal = "hello"
  ))
  expect_match(result, "version: \"1\\.0\"")
  expect_match(result, "auto_quoted: \"029\"")
  expect_match(result, "normal: hello")
})

test_that("as_yaml handles complex nested structures", {
  result <- as_yaml(list(
    metadata = list(
      invalid_octals = c("029", "089"),
      versions = c(yaml_quote_string("1.0"), yaml_quote_string("2.0")),
      names = c("alice", "bob")
    ),
    config = list(
      zip = "12345",
      code = "029"
    )
  ))
  expect_match(result, "- \"029\"")
  expect_match(result, "- \"089\"")
  expect_match(result, "- '1\\.0'")
  expect_match(result, "- '2\\.0'")
  expect_match(result, "- alice")
  expect_match(result, "- bob")
  expect_match(result, "zip: '12345'")
  expect_match(result, "code: \"029\"")
})

test_that("write_yaml_metadata_block produces YAML 1.2 compatible output", {
  expect_snapshot(cat(
    write_yaml_metadata_block(
      title = "Test Document",
      zip_code = "029",
      build = "0123",
      version = yaml_quote_string("1.0"),
      debug = TRUE
    )
  ))
})
