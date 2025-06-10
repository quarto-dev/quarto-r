# Create a blog post

    Code
      new_blog_post("Intro to Felt Surrogacy", data = "1999-12-31", open = FALSE)
    Condition
      Error in `new_blog_post()`:
      ! There is already a 'intro-to-felt-surrogacy' directory in 'posts/'

# Error if not a quarto project

    Code
      new_blog_post("Intro to Felt Surrogacy", open = FALSE)
    Condition
      Error in `new_blog_post()`:
      ! You need to be at root of a Quarto project to create a blog post in the 'posts/' directory at 'C:/Users/chris/AppData/Local/Temp/RtmpU72EnV/test-blog-project-415061be69e8'.

---

    Code
      new_blog_post("Intro to Felt Surrogacy", wd = withr::local_tempdir(pattern = "test-blog-project-2-"),
      open = FALSE)
    Condition
      Error in `new_blog_post()`:
      ! You need to be at root of a Quarto project to create a blog post in the 'posts/' directory at 'C:/Users/chris/AppData/Local/Temp/RtmpU72EnV/test-blog-project-2-4150447c3b64'.

