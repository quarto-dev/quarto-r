# Removing an extension

    Code
      withr::with_dir(wd, expect_false(quarto_remove_extension(
        "quarto-ext/fontawesome", no_prompt = TRUE)))
    Message
      ! "quarto-ext/fontawesome" is not among installed extensions.

---

    Code
      withr::with_dir(wd, expect_true(quarto_remove_extension(
        "quarto-ext/fontawesome", no_prompt = TRUE)))
    Message
      v Extension `quarto-ext/fontawesome` successfully removed.

