test_that("write_yaml_metadata_block handles basic arguments", {
  result <- write_yaml_metadata_block(title = "Test", author = "John Doe")
  expect_s3_class(result, "knit_asis")
  expect_match(
    result,
    "---\ntitle: Test\nauthor: John Doe\n---\n",
    fixed = TRUE
  )
})

test_that("write_yaml_metadata_block handles logical values correctly", {
  result <- write_yaml_metadata_block(admin = TRUE, debug = FALSE)
  expect_match(result, "admin: true")
  expect_match(result, "debug: false")
})

test_that("write_yaml_metadata_block handles .list parameter", {
  # Test with .list parameter only
  meta_list <- list(version = "1.0", status = "active")
  result <- write_yaml_metadata_block(.list = meta_list)
  expect_match(result, "version: '1.0'")
  expect_match(result, "status: active")
})

test_that("write_yaml_metadata_block merges ... and .list parameters", {
  meta_list <- list(version = "1.0", debug = FALSE)
  result <- write_yaml_metadata_block(title = "Test", .list = meta_list)
  expect_match(result, "title: Test")
  expect_match(result, "version: '1.0'")
  expect_match(result, "debug: false")
})

test_that("write_yaml_metadata_block handles empty input", {
  result <- write_yaml_metadata_block()
  expect_null(result)
})

test_that("write_yaml_metadata_block handles NULL .list", {
  # Test with NULL .list (should be ignored)
  result <- write_yaml_metadata_block(title = "Test", .list = NULL)
  expect_match(result, "---\ntitle: Test\n---\n", fixed = TRUE)
})

test_that("write_yaml_metadata_block handles complex data types", {
  # Test with various R data types
  current_date <- structure(20262, class = "Date")
  expect_snapshot(cat(write_yaml_metadata_block(
    title = "Complex Test",
    date = current_date,
    count = 42L,
    rate = 3.14,
    tags = c("r", "quarto", "test")
  )))
})

test_that("write_yaml_metadata_block handles nested lists", {
  # Test with nested list structures
  expect_snapshot(cat(
    write_yaml_metadata_block(
      format = list(
        html = list(toc = TRUE, theme = "bootstrap"),
        pdf = list(documentclass = "article")
      )
    )
  ))
})

test_that("write_yaml_metadata_block overrides .list with direct arguments", {
  # Test that direct arguments override .list values for same keys
  meta_list <- list(title = "From List", debug = TRUE)
  expect_snapshot(cat(
    write_yaml_metadata_block(
      title = "Direct Argument",
      author = "John",
      .list = meta_list
    )
  ))
})

test_that("write_yaml_metadata_block produces valid YAML structure", {
  result <- write_yaml_metadata_block(title = "Test", admin = TRUE)

  expect_match(result, "^---\\n")
  expect_match(result, "---\\n$")

  yaml_content <- gsub("^---\\n(.*)\\n---\\n$", "\\1", result)
  expect_no_error(yaml::yaml.load(yaml_content))
})

test_that("write_yaml_metadata_block handles special characters in values", {
  expect_snapshot(cat(
    write_yaml_metadata_block(
      title = "Test: A Study of R & Quarto",
      description = "This is a \"quoted\" string with 'mixed' quotes",
      path = "C:\\Users\\test\\file.txt"
    )
  ))
})

# test_that("write_yaml_metadata_block handles NA values", {
#   # Test with NA values
#   result <- write_yaml_metadata_block(
#     title = "Test",
#     missing_value = NA,
#     missing_char = NA_character_,
#     missing_num = NA_real_
#   )

#   expect_s3_class(result, "knit_asis")
#   expect_match(result, "title: Test")
#   # NA values should be converted to null in YAML
#   expect_match(result, "missing_value: ~")
# })

test_that("write_yaml_metadata_block handles empty lists and vectors", {
  # Test with empty collections
  expect_snapshot(cat(write_yaml_metadata_block(
    title = "Test",
    empty_list = list(),
    empty_vector = character(0),
    empty_numeric = numeric(0)
  )))
})
