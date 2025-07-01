# internal environment acting as storage and cache
# Using convention in https://github.com/tidyverse/design/issues/126
the <- rlang::new_environment(
  list(
    latest_stable = list(date = NULL, infos = NULL),
    latest_prerelease = list(date = NULL, infos = NULL)
  ),
  parent = emptyenv()
)
