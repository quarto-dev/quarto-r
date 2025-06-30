test_that("get_latest_info handles network errors gracefully", {
  # Mock network failure by using invalid URL
  with_mocked_bindings(
    get_json = function(url) stop("Network error"),
    {
      expect_error(get_latest_info("stable"), "Failed to fetch latest versions")
      expect_error(
        get_latest_info("prerelease"),
        "Failed to fetch latest versions"
      )
    }
  )
})

test_that("latest_available_version functions work with valid data", {
  skip_if_offline("quarto.org")

  stable_version <- latest_available_version("stable")
  prerelease_version <- latest_available_version("prerelease")

  expect_type(stable_version, "character")
  expect_type(prerelease_version, "character")
  expect_length(stable_version, 1)
  expect_length(prerelease_version, 1)

  # Versions should match semantic versioning pattern
  expect_match(stable_version, "^\\d+\\.\\d+\\.\\d+")
  expect_match(prerelease_version, "^\\d+\\.\\d+\\.\\d+")
})

test_that("latest_available_published works", {
  skip_if_offline("quarto.org")

  stable_published <- latest_available_published("stable")
  prerelease_published <- latest_available_published("prerelease")

  expect_type(stable_published, "character")
  expect_type(prerelease_published, "character")
  expect_length(stable_published, 1)
  expect_length(prerelease_published, 1)
  # valid date
  expect_no_error(as.Date(stable_published))
  expect_no_error(as.Date(prerelease_published))
})

test_that("check_newer_version handles development version", {
  expect_message(
    expect_invisible(
      expect_false(
        check_newer_version("99.9.9"),
        "Skipping version check for development version"
      )
    )
  )
  expect_no_message(
    expect_invisible(
      expect_false(
        check_newer_version("99.9.9", FALSE)
      )
    )
  )
})

test_that("check_newer_version handles stable version scenarios", {
  local_mocked_bindings(
    latest_available_version = function(type) {
      return("1.5.3")
    }
  )
  expect_snapshot(expect_invisible(expect_true(check_newer_version("1.0.0"))))
  expect_snapshot(expect_invisible(expect_false(check_newer_version("1.5.3"))))
})

test_that("check_newer_version handles prerelease version scenarios", {
  local_mocked_bindings(
    latest_available_version = function(type) {
      if (type == "stable") {
        return("1.5.3")
      } else {
        return("1.6.4")
      }
    }
  )

  expect_snapshot(
    expect_invisible(
      expect_true(
        check_newer_version("1.6.3")
      )
    )
  )
  expect_snapshot(
    expect_invisible(
      expect_false(
        check_newer_version("1.6.5")
      )
    )
  )
})

test_that("caching mechanism works", {
  # Clear any existing cache before
  if (exists("latest_stable", envir = the)) {
    rm("latest_stable", envir = the)
  }
  # and after
  withr::defer(
    rm("latest_stable", envir = the),
  )

  expect_null(the$latest_stable)

  with_mocked_bindings(
    default_infos = function(type) {
      return(
        list(
          date = Sys.Date(),
          infos = list(version = "1.5.3", published = "2023-01-01")
        )
      )
    },
    {
      expect_identical(latest_available_version("stable"), "1.5.3")
      expect_identical(the$latest_stable$infos$version, "1.5.3")
    }
  )

  # default infos should not be called again
  # so version should be cached and used
  with_mocked_bindings(
    default_infos = function(type) {
      return(
        list(
          date = Sys.Date(),
          infos = list(version = "1.7.3", published = "2025-01-01")
        )
      )
    },
    {
      expect_identical(latest_available_version("stable"), "1.5.3")
      expect_identical(the$latest_stable$infos$version, "1.5.3")
    }
  )
})

test_that("cache invalidation works", {
  # Mock an old cache entry
  old_cache <- list(
    date = Sys.Date() - 2, # 2 days old
    infos = list(version = "1.0.0", published = "2023-01-01")
  )

  # Set old cache
  rlang::env_poke(the, "latest_stable", old_cache)
  withr::defer(
    rlang::env_poke(the, "latest_stable", NULL)
  )

  # Should fetch new data since cache is expired
  local_mocked_bindings(
    latest_available_version = function(type) {
      if (type == "stable") {
        return("1.5.3")
      } else {
        return("1.6.4")
      }
    }
  )
  expect_identical(the$latest_stable$infos$version, "1.0.0")
  expect_identical(latest_available_version("stable"), "1.5.3")
})

test_that("argument validation works", {
  expect_error(get_latest_info("invalid"), "should be one of")
  expect_error(latest_available_version("invalid"), "should be one of")
  expect_error(latest_available_published("invalid"), "should be one of")
})
