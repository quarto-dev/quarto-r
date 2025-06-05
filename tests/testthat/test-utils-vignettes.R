test_that("don't auto install CTAN package on CRAN", {
  skip_on_cran()
  skip_if_not_installed("withr")
  withr::with_envvar(
    list(
      # simulate non CRAN
      "NOT_CRAN" = "false",
      # simulate R CMD check
      "_R_CHECK_LICENSE_" = "true"
    ),
    {
      expect_false(get_meta_for_pdf()$format$pdf$`latex-auto-install`)
    }
  )
  withr::with_envvar(
    list(
      "_R_CHECK_PACKAGE_NAME_" = NA
    ),
    {
      expect_true(get_meta_for_pdf()$format$pdf$`latex-auto-install`)
    }
  )
})
