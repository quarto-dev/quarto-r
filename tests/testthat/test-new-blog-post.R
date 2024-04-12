test_that("Create a blog post", {
  skip_if_no_quarto("1.4")

  tempdir <- withr::local_tempdir()
  withr::local_dir(tempdir)
  quarto_create_project(name = "test-blog-project", type = "blog",
                        dir = tempdir(), quiet = TRUE)

  # ------------------------------------------------------------------------------

  post_1 <- new_blog_post("Intro to Felt Surrogacy", date = "March 25, 2010",
                          open = FALSE)
  expect_true(fs::file_exists(post_1))
  expect_equal(fs::path_file(post_1), "index.qmd")

  post_1_dir <- fs::path_split(post_1)[[1]]
  post_1_dir <- post_1_dir[length(post_1_dir) - 1]
  expect_equal(post_1_dir, "intro-to-felt-surrogacy")

  post_1_content <- readLines(post_1)
  post_1_content <- paste0(post_1_content, collapse = "\n")
  expect_equal(
    post_1_content,
    "---\ntitle: Intro to Felt Surrogacy\nauthor: Max Kuhn\ndate: March 25, 2010\n---"
  )

  # ------------------------------------------------------------------------------

  expect_snapshot(
    new_blog_post("Intro to Felt Surrogacy", data = "1999-12-31", open = FALSE),
    error = TRUE
  )

  # ------------------------------------------------------------------------------

  post_2 <-
    new_blog_post(
      "Intro to Felt Surrogacy",
      dest = "The Science of Illusion",
      author = "Annie Edison",
      categories = c("shenanigans", "security"),
      open = FALSE)

  expect_true(fs::file_exists(post_2))
  expect_equal(fs::path_file(post_2), "index.qmd")

  post_2_dir <- fs::path_split(post_2)[[1]]
  post_2_dir <- post_2_dir[length(post_2_dir) - 1]
  expect_equal(post_2_dir, "The Science of Illusion")

  post_2_content <- readLines(post_2)
  post_2_exp <- c(
    "---", "title: Intro to Felt Surrogacy", "author: Annie Edison",
    "date: '2024-04-12'", "categories:", "- shenanigans", "- security", "---")
  expect_equal(post_2_content, post_2_exp)
})

