# Removing an extension

    Code
      expect_false(quarto_remove_extension("quarto-ext/fontawesome", no_prompt = TRUE))
    Message
      ! No extensions installed.

---

    Code
      expect_true(quarto_remove_extension("quarto-ext/fontawesome", no_prompt = TRUE))
    Message
      v Extension `quarto-ext/fontawesome` successfully removed.

