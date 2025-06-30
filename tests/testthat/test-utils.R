test_that("has_internet works correctly", {
  skip_if_offline("example.com")
  expect_true(has_internet("https://www.example.com/"))
  expect_false(has_internet("https://www.invalid-host-that-does-not-exist.com"))
})
