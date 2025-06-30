#' Internal package state
#' @noRd
the <- new.env(
  list(
    latest_stable = list(date = NULL, infos = NULL),
    latest_prerelease = list(date = NULL, infos = NULL)
  ),
  parent = emptyenv()
)
