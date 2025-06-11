test_that("options quarto.log.debug and env var R_QUARTO_LOG_DEBUG", {
  # clean state
  local_clean_state()
  expect_false(is_quarto_r_debug())
  withr::with_envvar(list(R_QUARTO_LOG_DEBUG = TRUE), {
    expect_true(is_quarto_r_debug())
    # option takes precedence over env var
    withr::with_options(list(quarto.log.debug = FALSE), {
      expect_false(is_quarto_r_debug())
    })
  })
  withr::with_options(list(quarto.log.debug = TRUE), {
    expect_true(is_quarto_r_debug())
  })
  withr::with_envvar(list(R_QUARTO_LOG_DEBUG = FALSE), {
    expect_false(is_quarto_r_debug())
    # option takes precedence over env var
    withr::with_options(list(quarto.log.debug = TRUE), {
      expect_true(is_quarto_r_debug())
    })
  })
})

test_that("quarto_log_level respects Quarto env var", {
  local_clean_state()
  expect_true(is.na(quarto_log_level()))
  expect_false(quarto_log_level("DEBUG"))
  withr::with_envvar(list(QUARTO_LOG_LEVEL = "DEBUG"), {
    expect_true(quarto_log_level("DEBUG"))
    expect_false(quarto_log_level("INFO"))
    expect_false(quarto_log_level("ERROR"))
  })
  withr::with_envvar(list(QUARTO_LOG_LEVEL = "INFO"), {
    expect_false(quarto_log_level("DEBUG"))
    expect_true(quarto_log_level("INFO"))
    expect_false(quarto_log_level("ERROR"))
  })
  withr::with_envvar(list(QUARTO_LOG_LEVEL = "ERROR"), {
    expect_false(quarto_log_level("DEBUG"))
    expect_false(quarto_log_level("INFO"))
    expect_true(quarto_log_level("ERROR"))
  })
})

test_that("in_debug_mode respects GHA CI env var", {
  local_clean_state()
  expect_false(in_debug_mode())

  withr::with_envvar(list(ACTIONS_RUNNER_DEBUG = "true"), {
    expect_true(in_debug_mode())
  })

  withr::with_envvar(list(ACTIONS_STEP_DEBUG = "true"), {
    expect_true(in_debug_mode())
  })

  withr::with_envvar(
    list(ACTIONS_RUNNER_DEBUG = "false", ACTIONS_STEP_DEBUG = "false"),
    {
      expect_false(in_debug_mode())
    }
  )
})

test_that("in_debug mode respects quarto_log_level", {
  # clean state
  local_clean_state()
  expect_false(in_debug_mode())

  withr::with_envvar(list(QUARTO_LOG_LEVEL = "DEBUG"), {
    expect_true(in_debug_mode())
  })

  withr::with_envvar(list(QUARTO_LOG_LEVEL = "INFO"), {
    expect_false(in_debug_mode())
  })

  withr::with_envvar(list(QUARTO_LOG_LEVEL = "ERROR"), {
    expect_false(in_debug_mode())
  })
})

test_that("in_debug_mode respects R_QUARTO_LOG_DEBUG and quarto.log.debug", {
  # clean state
  local_clean_state()
  expect_false(in_debug_mode())

  withr::with_envvar(list(R_QUARTO_LOG_DEBUG = TRUE), {
    expect_true(in_debug_mode())
    withr::with_options(list(quarto.log.debug = FALSE), {
      expect_false(in_debug_mode())
    })
    withr::with_options(list(quarto.log.debug = TRUE), {
      expect_true(in_debug_mode())
    })
  })

  withr::with_envvar(list(R_QUARTO_LOG_DEBUG = FALSE), {
    expect_false(in_debug_mode())
    withr::with_options(list(quarto.log.debug = TRUE), {
      expect_true(in_debug_mode())
    })
    withr::with_options(list(quarto.log.debug = FALSE), {
      expect_false(in_debug_mode())
    })
  })
})

test_that("quarto_log only logs when in debug mode", {
  temp_file <- withr::local_tempfile(fileext = ".log")

  local_clean_state()

  result <- quarto_log("test message", file = temp_file)
  expect_false(result)
  expect_false(file.exists(temp_file))

  # Test with debug mode on
  withr::with_options(list(quarto.log.debug = TRUE), {
    result <- quarto_log("test message", file = temp_file)
    expect_true(result)
    expect_true(file.exists(temp_file))

    content <- readLines(temp_file)
    expect_true(grepl("DEBUG: test message", content[1]))
    expect_true(grepl(
      "\\[\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\]",
      content[1]
    ))
  })
})

test_that("quarto_log respects log file configuration", {
  temp_file <- withr::local_tempfile(fileext = ".log")

  local_clean_state()

  withr::local_options(quarto.log.debug = TRUE)

  # Test with file parameter
  result <- quarto_log("direct file", file = temp_file)
  expect_true(result)
  expect_true(file.exists(temp_file))

  # Test with option
  unlink(temp_file)
  withr::with_options(list(quarto.log.file = temp_file), {
    result <- quarto_log("via option")
    expect_true(result)
    expect_true(file.exists(temp_file))
  })

  # Test with environment variable (R_QUARTO_LOG_FILE)
  unlink(temp_file)
  withr::with_envvar(list(R_QUARTO_LOG_FILE = temp_file), {
    result <- quarto_log("via env var")
    expect_true(result)
    expect_true(file.exists(temp_file))
  })

  # Test with no file configured - now uses default
  # Since get_log_file() now has a default, we need to test differently
  # The function should still return TRUE and use the default file path
  tempdir <- withr::local_tempdir("quarto-log-test")
  withr::with_dir(tempdir, {
    result <- quarto_log("no file configured")
    expect_true(result)
    # The default file should be created in the temp directory
    expect_true(file.exists("./quarto-r-debug.log"))
    # Clean up the default log file
    unlink("./quarto-r-debug.log")
  })
})

test_that("quarto_log handles custom formatting", {
  temp_file <- withr::local_tempfile(fileext = ".log")

  local_clean_state()

  withr::local_options(quarto.log.debug = TRUE)

  # Test without timestamp
  quarto_log("no timestamp", file = temp_file, timestamp = FALSE)
  content <- readLines(temp_file)
  expect_equal(content[1], "DEBUG: no timestamp")

  # Test without prefix
  quarto_log("no prefix", file = temp_file, prefix = "", append = FALSE)
  content <- readLines(temp_file)
  expect_true(grepl(
    "^\\[\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\] no prefix$",
    content[1]
  ))

  # Test custom prefix
  quarto_log(
    "custom prefix",
    file = temp_file,
    prefix = "CUSTOM: ",
    append = FALSE
  )
  content <- readLines(temp_file)
  expect_true(grepl("CUSTOM: custom prefix", content[1]))
})
