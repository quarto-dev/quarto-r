# check_params_for_na detects NA in simple vectors

    Code
      check_params_for_na(bad_params)
    Condition
      Error in `check_na_recursive()`:
      ! `NA` values detected in parameter values
      x Found NA at position: 2
      i Quarto parameters cannot contain NA values
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
      i Quarto parameters cannot contain NA values
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
      i Quarto parameters cannot contain NA values
        Consider these alternatives:
      * Remove NA values from your data before passing to Quarto
      * Use `NULL` instead of `NA` for missing optional parameters
      * Handle missing values within your document code using conditional logic

