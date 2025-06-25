test_that("tbl_qmd_span generates correct HTML with base64 encoding", {
  expect_match(
    tbl_qmd_span("**bold text**"),
    "<span data-qmd-base64=\"Kipib2xkIHRleHQqKg==\">**bold text**</span>",
    fixed = TRUE
  )
  expect_match(
    tbl_qmd_span("$\\alpha + \\beta$", display = "Greek formula"),
    "<span data-qmd-base64=\"JFxhbHBoYSArIFxiZXRhJA==\">Greek formula</span>",
    fixed = TRUE
  )
})

test_that("tbl_qmd_span_raw generates correct HTML with raw encoding", {
  expect_match(
    tbl_qmd_span_raw("Simple text"),
    "<span data-qmd=\"Simple text\">Simple text</span>",
    fixed = TRUE
  )
})

test_that("tbl_qmd_div generates correct HTML with base64 encoding", {
  # Test with default base64 encoding
  expect_match(
    tbl_qmd_div("## Section Title\n\nContent here"),
    "<div data-qmd-base64=\"IyMgU2VjdGlvbiBUaXRsZQoKQ29udGVudCBoZXJl\">## Section Title\n\nContent here</div>",
    fixed = TRUE
  )

  # Test with display text
  expect_match(
    tbl_qmd_div(
      "{{< video https://example.com >}}",
      display = "[Video content]"
    ),
    "<div data-qmd-base64=\"e3s8IHZpZGVvIGh0dHBzOi8vZXhhbXBsZS5jb20gPn19\">[Video content]</div>",
    fixed = TRUE
  )
})

test_that("tbl_qmd_div_raw generates correct HTML with raw encoding", {
  result <- tbl_qmd_div_raw("## Simple header")
  expect_true(grepl("<div data-qmd=", result))
  expect_false(grepl("<div data-qmd-base64=", result))
})

test_that(".validate_tbl_qmd_input validates inputs correctly", {
  # Valid inputs should return TRUE
  expect_true(.validate_tbl_qmd_input("content"))
  expect_true(.validate_tbl_qmd_input("content", "display"))

  # Invalid content should throw error
  expect_error(.validate_tbl_qmd_input(c("multiple", "strings")))
  expect_error(.validate_tbl_qmd_input(123))

  # Invalid display should throw error
  expect_error(.validate_tbl_qmd_input("content", c("multiple", "displays")))
  expect_error(.validate_tbl_qmd_input("content", 123))
})

test_that("tbl_qmd_div_base64 and tbl_qmd_span_base64 explicitly use base64 encoding", {
  expect_identical(
    tbl_qmd_div_base64("Content"),
    tbl_qmd_div("Content", use_base64 = TRUE)
  )
  expect_identical(
    tbl_qmd_span_base64("Content"),
    tbl_qmd_span("Content", use_base64 = TRUE)
  )
})

test_that(".tbl_qmd_element correctly handles different tag types", {
  expect_match(
    .tbl_qmd_element("span", "content", "display", TRUE),
    "<span data-qmd-base64=\"Y29udGVudA==\">display</span>",
    fixed = TRUE
  )

  expect_match(
    .tbl_qmd_element("div", "content", "display", TRUE),
    "<div data-qmd-base64=\"Y29udGVudA==\">display</div>",
    fixed = TRUE
  )
})

test_that(".tbl_qmd_element handles class and additional attributes", {
  expect_match(
    .tbl_qmd_element(
      "span",
      "content",
      "display",
      TRUE,
      class = "test-class",
      attrs = list(id = "test-id", tabindex = "0")
    ),
    "<span data-qmd-base64=\"Y29udGVudA==\" class=\"test-class\" id=\"test-id\" tabindex=\"0\">display</span>",
    fixed = TRUE
  )
})
