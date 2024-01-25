# quarto_run gives guidance in error

    Code
      quarto_run(c("rend", "--quiet"))
    Condition
      Error:
      ! Error running quarto cli:
      i Rerun with `quiet = FALSE` to see the full error message.
      Caused by error:
      ! System command 'quarto' failed

# is_using_quarto correctly check directory

    Code
      is_using_quarto(dirname(qmd), verbose = TRUE)
    Message
      At least one file `*.qmd` has been found.
    Output
      [1] TRUE

---

    Code
      is_using_quarto(dirname(qmd), verbose = TRUE)
    Message
      A '_quarto.yml' has been found.
    Output
      [1] TRUE

---

    Code
      is_using_quarto(dirname(qmd), verbose = TRUE)
    Message
      A '_quarto.yml' has been found.
    Output
      [1] TRUE

---

    Code
      is_using_quarto(dirname(qmd), verbose = TRUE)
    Message
      No '_quarto.yml' or `*.qmd` has been found.
    Output
      [1] FALSE

