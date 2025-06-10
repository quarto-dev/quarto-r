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
      ! You need to be at root of a Quarto project to create a blog post in the 'posts/' directory at '<project directory>'.

---

    Code
      new_blog_post("Intro to Felt Surrogacy", wd = tmp_dir, open = FALSE)
    Condition
      Error in `new_blog_post()`:
      ! You need to be at root of a Quarto project to create a blog post in the 'posts/' directory at '<project directory>'.

