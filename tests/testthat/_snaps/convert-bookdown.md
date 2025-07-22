# detect_bookdown_crossrefs works with valid single file

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 4 bookdown cross-references that should be converted:
      
      * '<test_file_basename>': 4 references
      - 1 Eq
      - 1 Fig
      - 1 Sec
      - 1 Tab
      
      i Summary of conversion requirements:
      * 1 Eq reference
      * 1 Fig reference
      * 1 Sec reference
      * 1 Tab reference
      
      i Manual conversion requirements:
      * Section headers: 1 reference need manual attention
      * Figure labels: 1 reference need manual attention
      * Table labels: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

# detect_bookdown_crossrefs works with valid directory

    Code
      result <- detect_bookdown_crossrefs(test_dir, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in 2 .Rmd files...
      ! Found 6 bookdown cross-references that should be converted:
      
      * '<test_file1>': 4 references
      - 1 Eq
      - 1 Fig
      - 1 Sec
      - 1 Tab
      
      * '<test_file2>': 2 references
      - 1 Eq
      - 1 Numbered Equation
      
      i Summary of conversion requirements:
      * 2 Eq reference
      * 1 Fig reference
      * 1 Numbered Equation reference
      * 1 Sec reference
      * 1 Tab reference
      
      i Manual conversion requirements:
      * Section headers: 1 reference need manual attention
      * Figure labels: 1 reference need manual attention
      * Table labels: 1 reference need manual attention
      * Equation structure: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_dir>", verbose = TRUE)`

# detect_bookdown_crossrefs handles invalid inputs gracefully

    Code
      result1 <- detect_bookdown_crossrefs("nonexistent/path")
    Message
      x Path does not exist: nonexistent/path

---

    Code
      result2 <- detect_bookdown_crossrefs(txt_file)
    Message
      i File must be a .qmd or .Rmd file.

---

    Code
      result3 <- detect_bookdown_crossrefs(empty_dir)
    Message
      i No .qmd or .Rmd files found in the directory.

# detect_bookdown_crossrefs verbose parameter works

    Code
      result_compact <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 4 bookdown cross-references that should be converted:
      
      * '<test_file_basename>': 4 references
      - 1 Eq
      - 1 Fig
      - 1 Sec
      - 1 Tab
      
      i Summary of conversion requirements:
      * 1 Eq reference
      * 1 Fig reference
      * 1 Sec reference
      * 1 Tab reference
      
      i Manual conversion requirements:
      * Section headers: 1 reference need manual attention
      * Figure labels: 1 reference need manual attention
      * Table labels: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

---

    Code
      result_verbose <- detect_bookdown_crossrefs(test_file, verbose = TRUE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 4 bookdown cross-references that should be converted:
      
      
      -- File: '<test_file_basename>' --
      
      -- Fig references: 
      * Line 2 ('<test_file_basename>:2'): `\@ref(fig:plot1)` -> `@fig-plot1`
      i   Note: Also ensure the corresponding code chunk has `#| label: fig-plot1`
      
      -- Eq references: 
      * Line 4 ('<test_file_basename>:4'): `\@ref(eq:mean)` -> `@eq-mean`
      
      -- Tab references: 
      * Line 3 ('<test_file_basename>:3'): `\@ref(tab:data)` -> `@tbl-data`
      i   Note: Also ensure the corresponding table has tbl prefxed id, either `{#tbl-data}` or `label="tbl-data"` in the r cell.
      
      -- Sec references: 
      * Line 5 ('<test_file_basename>:5'): `\@ref(methods)` -> `@sec-methods`
      i   Note: Also ensure the corresponding header has `{#sec-methods}`
      
      i Summary of conversion requirements:
      * 1 Eq reference
      * 1 Fig reference
      * 1 Sec reference
      * 1 Tab reference
      ! Section reference detected - requires manual header updates:
      Bookdown automatically generates IDs from headers like:
      `# Hello World` -> auto-generated ID: `hello-world`
      referenced with `\@ref(hello-world)`
      
      Quarto requires explicit header IDs:
      `# Hello World {#sec-hello-world}` -> explicit ID: `sec-hello-world `
      referenced with `@sec-hello-world`
      
      ! Figure reference detected - requires manual figure labeling:
      Bookdown automatically generates figure IDs from code chunk labels:
      ```{r mylabel, fig.cap='My Figure'}
      plot(mtcars)
      ``` -> auto-generated ID: `fig:mylabel`
      referenced with `\@ref(fig:mylabel)`
      
      Quarto requires explicit figure IDs with fig prefix:
      ```{r}
      #| label: fig-mylabel
      #| fig-cap: 'My Figure'
      plot(mtcars)
      ```
      referenced with `@fig-mylabel`
      
      See documentation:
      Bookdown: <https://bookdown.org/yihui/bookdown/figures.html>
      Quarto: <https://quarto.org/docs/authoring/figures.html#cross-references>
      
      ! Table reference detected - requires manual table labeling:
      Bookdown automatically generates table IDs from kable/knitr functions based on
      cell label:
      ```{r mylabel}
      kable(mtcars, caption = 'My Table')
      ``` -> auto-generated ID: `tab:mylabel`
      referenced with `\@ref(tab:mylabel)`
      
      Quarto requires explicit table IDs with tbl prefix in R code chunks:
      ```{r}
      #| label: tbl-mylabel
      #| tbl-cap: 'My Table'
      kable(mtcars)
      ```
      referenced with `@tbl-mylabel`
      
      See documentation:
      Bookdown: <https://bookdown.org/yihui/bookdown/tables.html>
      Quarto: <https://quarto.org/docs/authoring/tables.html#cross-references>
      

# detect_bookdown_crossrefs returns NULL when no cross-references found

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      v No bookdown cross-references found. No conversion needed.

# detects figure cross-references correctly

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      * '<test_file_basename>': 1 reference
      - 1 Fig
      
      i Summary of conversion requirements:
      * 1 Fig reference
      
      i Manual conversion requirements:
      * Figure labels: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

---

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = TRUE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      
      -- File: '<test_file_basename>' --
      
      -- Fig references: 
      * Line 2 ('<test_file_basename>:2'): `\@ref(fig:plot1)` -> `@fig-plot1`
      i   Note: Also ensure the corresponding code chunk has `#| label: fig-plot1`
      
      i Summary of conversion requirements:
      * 1 Fig reference
      ! Figure reference detected - requires manual figure labeling:
      Bookdown automatically generates figure IDs from code chunk labels:
      ```{r mylabel, fig.cap='My Figure'}
      plot(mtcars)
      ``` -> auto-generated ID: `fig:mylabel`
      referenced with `\@ref(fig:mylabel)`
      
      Quarto requires explicit figure IDs with fig prefix:
      ```{r}
      #| label: fig-mylabel
      #| fig-cap: 'My Figure'
      plot(mtcars)
      ```
      referenced with `@fig-mylabel`
      
      See documentation:
      Bookdown: <https://bookdown.org/yihui/bookdown/figures.html>
      Quarto: <https://quarto.org/docs/authoring/figures.html#cross-references>
      

# detects table cross-references correctly

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      * '<test_file_basename>': 1 reference
      - 1 Tab
      
      i Summary of conversion requirements:
      * 1 Tab reference
      
      i Manual conversion requirements:
      * Table labels: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

---

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = TRUE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      
      -- File: '<test_file_basename>' --
      
      -- Tab references: 
      * Line 2 ('<test_file_basename>:2'): `\@ref(tab:data)` -> `@tbl-data`
      i   Note: Also ensure the corresponding table has tbl prefxed id, either `{#tbl-data}` or `label="tbl-data"` in the r cell.
      
      i Summary of conversion requirements:
      * 1 Tab reference
      ! Table reference detected - requires manual table labeling:
      Bookdown automatically generates table IDs from kable/knitr functions based on
      cell label:
      ```{r mylabel}
      kable(mtcars, caption = 'My Table')
      ``` -> auto-generated ID: `tab:mylabel`
      referenced with `\@ref(tab:mylabel)`
      
      Quarto requires explicit table IDs with tbl prefix in R code chunks:
      ```{r}
      #| label: tbl-mylabel
      #| tbl-cap: 'My Table'
      kable(mtcars)
      ```
      referenced with `@tbl-mylabel`
      
      See documentation:
      Bookdown: <https://bookdown.org/yihui/bookdown/tables.html>
      Quarto: <https://quarto.org/docs/authoring/tables.html#cross-references>
      

# detects numbered equations correctly

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      * '<test_file_basename>': 1 reference
      - 1 Numbered Equation
      
      i Summary of conversion requirements:
      * 1 Numbered Equation reference
      
      i Manual conversion requirements:
      * Equation structure: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

---

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = TRUE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      
      -- File: '<test_file_basename>' --
      
      -- Numbered Equation references: 
      * Line 4 ('<test_file_basename>:4'): `(\#eq:binom)` -> `{#eq-binom}`
      !   Requires manual conversion: Equation structure must be changed
      
      i Summary of conversion requirements:
      * 1 Numbered Equation reference
      ! Numbered equation detected - requires manual restructuring:
      Bookdown numbered equations:
      \begin{equation}
      f\left(k\right) = \binom{n}{k} p^k\left(1-p\right)^{n-k}
      (\#eq:binom)
      \end{equation}
      Quarto numbered equations:
      $$\bar{X} = \frac{1}{n} \sum_{i=1}^{n} X_i$$ {#eq-mean}
      
      See documentation:
      Bookdown:
      <https://bookdown.org/yihui/bookdown/markdown-extensions-by-bookdown.html#equations>
      Quarto: <https://quarto.org/docs/authoring/cross-references.html#equations>
      

# detects unsupported cross-references correctly

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      * '<test_file_basename>': 1 reference
      - 1 Cnj Unsupported
      
      i Summary of conversion requirements:
      * 1 Cnj reference (NOT SUPPORTED IN QUARTO)
      
      i Manual conversion requirements:
      * Unsupported types: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

---

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = TRUE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      
      -- File: '<test_file_basename>' --
      
      -- Cnj references (NOT SUPPORTED IN QUARTO): 
      * Line 2 ('<test_file_basename>:2'): `\@ref(cnj:guess)` -> `NOT SUPPORTED IN
      QUARTO`
      x   Not supported in Quarto: Consider custom cross-references (<https://quarto.org/docs/authoring/cross-references-custom.html>) or supported theorem types.
      
      i Summary of conversion requirements:
      * 1 Cnj reference (NOT SUPPORTED IN QUARTO)
      x Cross-references to types not supported in Quarto
      
      The following bookdown cross-reference types are not supported in Quarto:
      * Conjecture (cnj)
      * Hypothesis (hyp)
      
      Consider these alternatives:
      * Convert to regular text without cross-references
      * Use supported theorem types (theorem, lemma, corollary, etc.)
      * Create custom callout blocks with manual numbering
      

# detects theorem block with label correctly

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 2 bookdown cross-references that should be converted:
      
      * '<test_file_basename>': 2 references
      - 1 Lem
      - 1 Lemma Block Labeled
      
      i Summary of conversion requirements:
      * 1 Lem reference
      * 1 Lemma Block Labeled reference
      
      i Manual conversion requirements:
      * Theorem blocks: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

---

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = TRUE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 2 bookdown cross-references that should be converted:
      
      
      -- File: '<test_file_basename>' --
      
      -- Lemma Block Labeled references: 
      * Line 2 ('<test_file_basename>:2'): `` ```{lemma label="important", name="Helper Lemma"} `` ->
      `:::{#lemma-important}`
      
      -- Lem references: 
      * Line 5 ('<test_file_basename>:5'): `\@ref(lem:important)` -> `@lem-important`
      
      i Summary of conversion requirements:
      * 1 Lem reference
      * 1 Lemma Block Labeled reference
      ! Theorem environments require manual restructuring
      Bookdown old syntax WITH label: ```{theorem, label="label"}
      Quarto syntax: :::{#thm-label}
      See: <https://quarto.org/docs/authoring/cross-references.html#theorems-and-proofs>
      

# detects theorem block without label correctly

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      * '<test_file_basename>': 1 reference
      - 1 Theorem Block Unlabeled
      
      i Summary of conversion requirements:
      * 1 Theorem Block Unlabeled reference
      
      i Manual conversion requirements:
      * Theorem blocks: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

---

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = TRUE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 1 bookdown cross-reference that should be converted:
      
      
      -- File: '<test_file_basename>' --
      
      -- Theorem Block Unlabeled references: 
      * Line 2 ('<test_file_basename>:2'): `` ```{theorem name="Pythagorean theorem"} `` -> `Manual
      conversion required: Use ::: {#thm-<id>} syntax. See
      https://quarto.org/docs/authoring/cross-references.html#theorems-and-proofs`
      
      i Summary of conversion requirements:
      * 1 Theorem Block Unlabeled reference
      ! Theorem environments require manual restructuring
      Bookdown old syntax WITHOUT label: ```{theorem chunk_name}
      Quarto syntax: :::{#thm-label}
      See: <https://quarto.org/docs/authoring/cross-references.html#theorems-and-proofs>
      

# detects theorem div syntax correctly

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = FALSE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 2 bookdown cross-references that should be converted:
      
      * '<test_file_basename>': 2 references
      - 1 Theorem Div
      - 1 Thm
      
      i Summary of conversion requirements:
      * 1 Theorem Div reference
      * 1 Thm reference
      
      i Manual conversion requirements:
      * Theorem blocks: 1 reference need manual attention
      
      i For detailed conversion guidance, run: `quarto::detect_bookdown_crossrefs("<test_file>", verbose = TRUE)`

---

    Code
      result <- detect_bookdown_crossrefs(test_file, verbose = TRUE)
    Message
      i Scanning for bookdown cross-references in file: <test_file_basename> (<file://<test_file>>).
      ! Found 2 bookdown cross-references that should be converted:
      
      
      -- File: '<test_file_basename>' --
      
      -- Theorem Div references: 
      * Line 2 ('<test_file_basename>:2'): `::: {.theorem #pyth-new name="Pythagorean
      theorem"}` -> `:::{#thm-pyth-new}`
      
      -- Thm references: 
      * Line 7 ('<test_file_basename>:7'): `\@ref(thm:pyth-new)` -> `@thm-pyth-new`
      
      i Summary of conversion requirements:
      * 1 Theorem Div reference
      * 1 Thm reference
      ! Theorem environments require manual restructuring
      Bookdown new div syntax: :::{.theorem #thm-label}
      Quarto syntax: :::{#thm-label}
      See:
      <https://quarto.org/docs/authoring/cross-references.html#theorems-and-proofs>
      

