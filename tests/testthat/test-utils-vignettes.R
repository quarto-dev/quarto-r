test_that("don't auto install CTAN package on CRAN", {
  skip_if_not_installed("withr")
  withr::with_envvar(list("NOT_CRAN" = "false", "_R_CHECK_LICENSE_" = "true"), {
    expect_false(get_meta_for_pdf()$format$pdf$`latex-auto-install`)
  })
  expect_true(get_meta_for_pdf()$format$pdf$`latex-auto-install`)
})
