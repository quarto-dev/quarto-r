# check_params_for_na detects NA in simple vectors

    Code
      check_params_for_na(bad_params)
    Condition
      Error in `check_na_recursive()`:
      ! `NA` values detected in parameter values
      x Found NA at position: 2
      i Quarto CLI uses YAML 1.2 spec which cannot process R's `NA` values
      i R's `NA` gets converted to YAML strings (like `.na.real`) that Quarto doesn't recognize as missing values
        Consider these alternatives:
      * Remove NA values from your data before passing to Quarto
      * Use `NULL` instead of `NA` for missing optional parameters
      * Handle missing values within your document code using conditional logic

# check_params_for_na detects NA in nested structures

    Code
      check_params_for_na(nested_params)
    Condition
      Error in `check_na_recursive()`:
      ! `NA` values detected in parameter data$subset
      x Found NA at position: 2
      i Quarto CLI uses YAML 1.2 spec which cannot process R's `NA` values
      i R's `NA` gets converted to YAML strings (like `.na.real`) that Quarto doesn't recognize as missing values
        Consider these alternatives:
      * Remove NA values from your data before passing to Quarto
      * Use `NULL` instead of `NA` for missing optional parameters
      * Handle missing values within your document code using conditional logic

# check_params_for_na shows correct NA positions

    Code
      check_params_for_na(multi_na_params)
    Condition
      Error in `check_na_recursive()`:
      ! `NA` values detected in parameter x
      x Found NA at positions: 2 and 4
      i Quarto CLI uses YAML 1.2 spec which cannot process R's `NA` values
      i R's `NA` gets converted to YAML strings (like `.na.real`) that Quarto doesn't recognize as missing values
        Consider these alternatives:
      * Remove NA values from your data before passing to Quarto
      * Use `NULL` instead of `NA` for missing optional parameters
      * Handle missing values within your document code using conditional logic

# as_yaml detects NA in simple vectors

    Code
      as_yaml(list(values = c(1, NA, 3)))
    Condition
      Error in `check_na_recursive()`:
      ! `NA` values detected in parameter values
      x Found NA at position: 2
      i Quarto CLI uses YAML 1.2 spec which cannot process R's `NA` values
      i R's `NA` gets converted to YAML strings (like `.na.real`) that Quarto doesn't recognize as missing values
        Consider these alternatives:
      * Remove NA values from your data before passing to Quarto
      * Use `NULL` instead of `NA` for missing optional parameters
      * Handle missing values within your document code using conditional logic

# write_yaml detects NA in nested structures

    Code
      write_yaml(list(data = list(subset = c(1, NA, 3))), tempfile())
    Condition
      Error in `check_na_recursive()`:
      ! `NA` values detected in parameter data$subset
      x Found NA at position: 2
      i Quarto CLI uses YAML 1.2 spec which cannot process R's `NA` values
      i R's `NA` gets converted to YAML strings (like `.na.real`) that Quarto doesn't recognize as missing values
        Consider these alternatives:
      * Remove NA values from your data before passing to Quarto
      * Use `NULL` instead of `NA` for missing optional parameters
      * Handle missing values within your document code using conditional logic

# as_yaml shows correct NA positions

    Code
      as_yaml(list(x = c(1, NA, 3, NA)))
    Condition
      Error in `check_na_recursive()`:
      ! `NA` values detected in parameter x
      x Found NA at positions: 2 and 4
      i Quarto CLI uses YAML 1.2 spec which cannot process R's `NA` values
      i R's `NA` gets converted to YAML strings (like `.na.real`) that Quarto doesn't recognize as missing values
        Consider these alternatives:
      * Remove NA values from your data before passing to Quarto
      * Use `NULL` instead of `NA` for missing optional parameters
      * Handle missing values within your document code using conditional logic

# quarto_render uses write_yaml validation

    Code
      quarto_render("test.qmd", execute_params = list(bad_param = c(1, NA)))
    Condition
      Error in `check_na_recursive()`:
      ! `NA` values detected in parameter bad_param
      x Found NA at position: 2
      i Quarto CLI uses YAML 1.2 spec which cannot process R's `NA` values
      i R's `NA` gets converted to YAML strings (like `.na.real`) that Quarto doesn't recognize as missing values
        Consider these alternatives:
      * Remove NA values from your data before passing to Quarto
      * Use `NULL` instead of `NA` for missing optional parameters
      * Handle missing values within your document code using conditional logic

# write_yaml_metadata_block produces YAML 1.2 compatible output

    Code
      cat(write_yaml_metadata_block(title = "Test Document", zip_code = "029", build = "0123",
        version = yaml_quote_string("1.0"), debug = TRUE))
    Output
      ---
      title: Test Document
      zip_code: "029"
      build: '0123'
      version: "1.0"
      debug: true
      ---

