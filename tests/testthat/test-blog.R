test_that("Create a blog post", {
  skip_if_no_quarto("1.4")
  skip_if_not_installed("whoami")

  dir_path <- withr::local_tempdir(pattern = "test-blog-project-")
  withr::local_dir(dir_path)

  proj_name <- "test-blog-project"

  quarto_create_project(
    name = proj_name,
    type = "blog",
    dir = dir_path,
    quiet = TRUE,
    no_prompt = TRUE
  )

  withr::local_dir(proj_name)

  withr::local_envvar(list(FULLNAME = "Max Kuhn"))

  # ------------------------------------------------------------------------------

  post_1 <- new_blog_post(
    "Intro to Felt Surrogacy",
    date = "March 25, 2010",
    open = FALSE
  )
  expect_true(fs::file_exists(post_1))
  expect_equal(fs::path_file(post_1), "index.qmd")

  expect_equal(fs::path_file(fs::path_dir(post_1)), "intro-to-felt-surrogacy")

  post_1_content <- rmarkdown::yaml_front_matter(post_1)
  expect_equal(post_1_content$title, "Intro to Felt Surrogacy")
  expect_equal(post_1_content$author, "Max Kuhn")
  expect_equal(post_1_content$date, "March 25, 2010")

  # ------------------------------------------------------------------------------

  expect_snapshot(
    error = TRUE,
    new_blog_post("Intro to Felt Surrogacy", data = "1999-12-31", open = FALSE)
  )

  # ------------------------------------------------------------------------------

  post_2 <-
    new_blog_post(
      "Intro to Felt Surrogacy",
      dest = "The Science of Illusion",
      author = "Annie Edison",
      date = '2024-04-12',
      categories = c("shenanigans", "security"),
      open = FALSE
    )

  expect_true(fs::file_exists(post_2))
  expect_equal(fs::path_file(post_2), "index.qmd")
  expect_equal(fs::path_file(fs::path_dir(post_2)), "The Science of Illusion")

  post_2_content <- rmarkdown::yaml_front_matter(post_2)
  expect_equal(post_2_content$title, "Intro to Felt Surrogacy")
  expect_equal(post_2_content$author, "Annie Edison")
  expect_equal(post_2_content$date, "2024-04-12")
  expect_equal(post_2_content$categories, c("shenanigans", "security"))
})

test_that("Error if not a quarto project", {
  dir_path <- withr::local_tempdir(pattern = "test-blog-project-")
  withr::local_dir(dir_path)

  expect_snapshot(
    error = TRUE,
    transform = hide_path(dir_path),
    new_blog_post("Intro to Felt Surrogacy", open = FALSE),
  )

  tmp_dir <- withr::local_tempdir(pattern = "test-blog-project-2-")
  expect_snapshot(
    error = TRUE,
    transform = hide_path(tmp_dir),
    new_blog_post(
      "Intro to Felt Surrogacy",
      wd = tmp_dir,
      open = FALSE
    ),
  )
})
