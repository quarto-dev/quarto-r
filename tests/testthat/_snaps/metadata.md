# write_yaml_metadata_block handles complex data types

    Code
      cat(write_yaml_metadata_block(title = "Complex Test", date = current_date,
        count = 42L, rate = 3.14, tags = c("r", "quarto", "test")))
    Output
      ---
      title: Complex Test
      date: 20262.0
      count: 42
      rate: 3.14
      tags:
      - r
      - quarto
      - test
      ---

# write_yaml_metadata_block handles nested lists

    Code
      cat(write_yaml_metadata_block(format = list(html = list(toc = TRUE, theme = "bootstrap"),
      pdf = list(documentclass = "article"))))
    Output
      ---
      format:
        html:
          toc: true
          theme: bootstrap
        pdf:
          documentclass: article
      ---

# write_yaml_metadata_block overrides .list with direct arguments

    Code
      cat(write_yaml_metadata_block(title = "Direct Argument", author = "John",
        .list = meta_list))
    Output
      ---
      title: Direct Argument
      debug: true
      author: John
      ---

# write_yaml_metadata_block handles special characters in values

    Code
      cat(write_yaml_metadata_block(title = "Test: A Study of R & Quarto",
        description = "This is a \"quoted\" string with 'mixed' quotes", path = "C:\\Users\\test\\file.txt"))
    Output
      ---
      title: 'Test: A Study of R & Quarto'
      description: This is a "quoted" string with 'mixed' quotes
      path: C:\Users\test\file.txt
      ---

# write_yaml_metadata_block handles empty lists and vectors

    Code
      cat(write_yaml_metadata_block(title = "Test", empty_list = list(),
      empty_vector = character(0), empty_numeric = numeric(0)))
    Output
      ---
      title: Test
      empty_list: []
      empty_vector: []
      empty_numeric: []
      ---

