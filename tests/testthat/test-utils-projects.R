test_that("project_path() works with explicit root", {
  temp_dir <- withr::local_tempdir()
  withr::local_dir(temp_dir)
  expect_identical(
    project_path("data", "file.csv", root = temp_dir),
    file.path("data", "file.csv")
  )
  expect_identical(
    project_path("outputs", "figures", "plot.png", root = temp_dir),
    file.path("outputs", "figures", "plot.png")
  )
  expect_identical(project_path(root = temp_dir), ".")
})

test_that("project_path() uses Quarto environment variables", {
  temp_dir <- withr::local_tempdir()
  withr::local_dir(temp_dir)
  dir.create("project")
  withr::with_envvar(
    c(
      QUARTO_PROJECT_ROOT = xfun::normalize_path(file.path(
        temp_dir,
        "project"
      )),
      QUARTO_PROJECT_DIR = NA
    ),
    expect_identical(
      project_path("data", "file.csv"),
      file.path("project", "data", "file.csv")
    )
  )
  withr::with_envvar(
    c(
      QUARTO_PROJECT_ROOT = NA,
      QUARTO_PROJECT_DIR = xfun::normalize_path(file.path(temp_dir, "project"))
    ),
    {
      expect_identical(
        get_running_project_root(),
        xfun::normalize_path(file.path(temp_dir, "project"))
      )

      expect_identical(
        project_path("data", "file.csv"),
        file.path("project", "data", "file.csv")
      )
    }
  )
})

test_that("project_path() detects Quarto project files", {
  skip_if_no_quarto()

  project_dir <- local_quarto_project(type = "blog")
  # simulate running from a post directory withing .qmd
  post_dir <- file.path(project_dir, "posts", "welcome")
  withr::local_dir(post_dir)
  # data is at root of the project and path should be relative to that
  expect_identical(
    project_path("data", "file.csv"),
    "../../data/file.csv"
  )
})

test_that("project_path() detects R package DESCRIPTION", {
  temp_dir <- withr::local_tempdir()
  desc_file <- file.path(temp_dir, "DESCRIPTION")
  writeLines(c("Package: testpkg", "Version: 1.0.0"), desc_file)
  withr::local_dir(temp_dir)
  dir.create("reports")
  withr::local_dir("reports")
  expect_identical(
    project_path("R", "functions.R"),
    "../R/functions.R"
  )
})

test_that("project_path() detects .Rproj files", {
  temp_dir <- withr::local_tempdir()
  rproj_file <- file.path(temp_dir, "test.Rproj")
  writeLines("Version: 1.0", rproj_file)
  withr::local_dir(temp_dir)
  dir.create("reports")
  withr::local_dir("reports")
  expect_identical(
    project_path("analysis", "script.R"),
    "../analysis/script.R"
  )
})

test_that("project_path() falls back to working directory with warning", {
  temp_dir <- withr::local_tempdir()
  withr::local_dir(temp_dir)
  withr::local_envvar(
    QUARTO_PROJECT_ROOT = "",
    QUARTO_PROJECT_DIR = ""
  )

  expect_warning(
    expect_identical(
      project_path("data", "file.csv"),
      file.path("data", "file.csv")
    ),
    "Failed to determine project root"
  )
})

test_that("project_path() handles xfun::proj_root() errors gracefully", {
  temp_dir <- withr::local_tempdir()

  # Mock xfun::proj_root to throw an error
  local_mocked_bindings(
    proj_root = function(path = ".", rules = xfun::root_rules) {
      stop("Test error")
    },
    .package = "xfun"
  )

  withr::local_dir(temp_dir)
  withr::local_envvar(
    QUARTO_PROJECT_ROOT = "",
    QUARTO_PROJECT_DIR = ""
  )

  expect_warning(
    expect_identical(
      project_path("data", "file.csv"),
      file.path("data", "file.csv")
    ),
    "Failed to determine project root: Test error"
  )
})

test_that("get_running_project_root() detects environment variables", {
  withr::with_envvar(
    c(
      QUARTO_PROJECT_ROOT = NA,
      QUARTO_PROJECT_DIR = NA
    ),
    expect_null(get_running_project_root())
  )

  withr::with_envvar(
    c(
      QUARTO_PROJECT_ROOT = "/some/path",
      QUARTO_PROJECT_DIR = NA
    ),
    expect_identical(get_running_project_root(), "/some/path")
  )

  withr::with_envvar(
    c(
      QUARTO_PROJECT_ROOT = NA,
      QUARTO_PROJECT_DIR = "/some/path"
    ),
    expect_identical(get_running_project_root(), "/some/path")
  )

  withr::with_envvar(
    c(
      QUARTO_PROJECT_ROOT = "/path1",
      QUARTO_PROJECT_DIR = "/path2"
    ),
    expect_identical(get_running_project_root(), "/path1")
  )
})

test_that("find_project_root() detects Quarto project files", {
  skip_if_no_quarto()

  temp_dir <- withr::local_tempdir()
  expect_null(find_project_root(temp_dir))

  project_dir <- local_quarto_project("test-project", type = "default")
  expect_match(
    find_project_root(project_dir),
    "quarto-tests-project-.*/test-project$"
  )

  withr::with_dir(
    project_dir,
    expect_match(
      find_project_root(),
      "quarto-tests-project-.*/test-project$"
    )
  )
})

test_that("find_project_root() works with _quarto.yaml", {
  temp_dir <- withr::local_tempdir()

  quarto_yaml <- file.path(temp_dir, "_quarto.yaml")
  writeLines("project:\n  type: default", quarto_yaml)

  expect_identical(find_project_root(temp_dir), xfun::normalize_path(temp_dir))

  withr::local_dir(temp_dir)
  expect_identical(find_project_root(), xfun::normalize_path(temp_dir))

  dir.create("subfolder")
  expect_identical(
    find_project_root("subfolder"),
    xfun::normalize_path(temp_dir)
  )
  withr::local_dir("subfolder")
  expect_identical(find_project_root(), xfun::normalize_path(temp_dir))
})

test_that("project_path() prioritizes environment variables over file detection", {
  skip_if_no_quarto()

  temp1 <- withr::local_tempdir()
  temp2 <- withr::local_tempdir()

  quarto_create_project(
    name = "test_project",
    type = "default",
    dir = temp1,
    no_prompt = TRUE,
    quiet = TRUE
  )

  withr::local_envvar(
    QUARTO_PROJECT_ROOT = "",
    QUARTO_PROJECT_DIR = ""
  )
  project_dir <- file.path(temp1, "test_project")
  dir.create(file.path(project_dir, "subfolder"))
  withr::local_dir(file.path(project_dir, "subfolder"))

  expect_identical(project_path("test.txt"), "../test.txt")

  # With env var, should use env var instead
  withr::local_envvar(QUARTO_PROJECT_ROOT = file.path(project_dir, "subfolder"))
  expect_identical(
    project_path("test.txt"),
    "test.txt"
  )
})
