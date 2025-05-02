# quarto_run gives guidance in error

    Code
      quarto_run(c("rend", "--quiet"))
    Condition
      Error:
      x Error running quarto cli.
      i Rerun with `quiet = FALSE` to see the full error message.
      Caused by error:
      ! System command 'quarto' failed

# quarto_run report full quarto cli error message

    Code
      quarto_inspect()
    Condition
      Error in `quarto_inspect()`:
      x Error running quarto cli.
        -------------------------
        ERROR: Book chapter 'intro.qmd' not found
        
        Stack trace:
        at throwInputNotFound (file:///<quarto full path>/quarto.js:100761:19)
        at findInputs (file:///<quarto full path>/quarto.js:100792:17)
        at eventLoopTick (ext:core/01_core.js:175:7)
        at async findChapters (file:///<quarto full path>/quarto.js:100804:13)
        at async bookRenderItems (file:///<quarto full path>/quarto.js:100807:5)
        at async Object.bookProjectConfig [as config] (file:///<quarto full path>/quarto.js:100712:25)
        at async projectContext (file:///<quarto full path>/quarto.js:82390:38)
        at async inspectConfig (file:///<quarto full path>/quarto.js:110378:21)
        at async Command.actionHandler (file:///<quarto full path>/quarto.js:110497:20)
        at async Command.execute (file:///<quarto full path>/quarto.js:8253:13)
        
      Caused by error:
      ! System command 'quarto.exe' failed

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

# quarto CLI sitrep

    Code
      quarto_binary_sitrep(debug = TRUE)
    Message
      v quarto R package will use '<QUARTO_PATH path>'
      ! It is configured through `QUARTO_PATH` environment variable. RStudio IDE will likely use another binary.
    Output
      [1] FALSE

---

    Code
      quarto_binary_sitrep(debug = TRUE)
    Message
      v quarto R package will use '<quarto full path>'
      i     It is configured to use the latest version found in the PATH environment variable.
      x RStudio IDE render button seems configured to use '<RSTUDIO_QUARTO path>'.
      !     It is configured through `RSTUDIO_QUARTO` environment variable.
    Output
      [1] FALSE

---

    Code
      quarto_binary_sitrep(debug = TRUE)
    Message
      v quarto R package will use '<quarto full path>'
      i     It is configured to use the latest version found in the PATH environment variable.
    Output
      [1] TRUE

---

    Code
      quarto_binary_sitrep(debug = TRUE)
    Message
      x Quarto command-line tools path not found! Please make sure you have installed and added Quarto to your PATH or set the QUARTO_PATH environment variable.
    Output
      [1] FALSE

