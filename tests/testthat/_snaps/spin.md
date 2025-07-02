# add_spin_preamble checks for file existence

    Code
      add_spin_preamble("non_existent_file.R")
    Condition
      Error in `add_spin_preamble()`:
      ! File 'non_existent_file.R' does not exist.
      Please provide a valid file path.

# add_spin_preamble validates preamble argument

    Code
      add_spin_preamble(tmp_file, preamble = "not a list")
    Condition
      Error in `add_spin_preamble()`:
      ! `preamble` must be a named list.

