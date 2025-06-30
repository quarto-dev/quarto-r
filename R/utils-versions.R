#' Check for newer version of Quarto
#'
#' Checks if a newer version of Quarto is available and informs the user about
#' their current version status. The function compares the current Quarto version
#' against the latest stable and prerelease versions available online.
#'
#' @param version Character string specifying the Quarto version to check.
#'   Defaults to the currently installed version detected by [quarto_version()].
#'   Use "99.9.9" to indicate a development version.
#' @param verbose Logical indicating whether to print informational messages.
#'   Defaults to `TRUE`. When `FALSE`, the function runs silently and only
#'   returns the logical result.
#'
#' @return Invisibly returns a logical value:
#'   - `TRUE` if an update is available
#'   - `FALSE` if no update is needed or when using development version
#'   The function is primarily called for its side effects of printing
#'   informational messages (when `verbose = TRUE`).
#'
#' @details
#' The function handles three scenarios:
#'   -  **Development version** (99.9.9): Skips version check with informational message
#'   -  **Prerelease version**: Compares against latest prerelease and informs about updates
#'   -  **Stable version**: Compares against latest stable version and suggests updates if needed
#'
#' Version information is fetched from Quarto's download JSON endpoints and cached in current session
#' for up to 24 hours to avoid repeated network requests.
#'
#' @section Network Requirements:
#' This function requires an internet connection to fetch the latest version
#' information from quarto.org. If the network request fails, an error will be thrown.
#'
#' @examplesIf quarto::quarto_available() && quarto:::has_internet("https://www.quarto.org")
#' # Check current Quarto version
#' check_newer_version()
#'
#' # Check a specific version
#' check_newer_version("1.7.30")
#'
#' # Check development version (will skip check)
#' check_newer_version("99.9.9")
#'
#' # Check silently without messages
#' result <- check_newer_version(verbose = FALSE)
#' if (result) {
#'   message("Update available!")
#' }
#'
#' @seealso
#' [quarto_version()] for getting the current Quarto version,
#'
#' @export
check_newer_version <- function(version = quarto_version(), verbose = TRUE) {
  inform_if_verbose <- function(...) {
    void <- function(...) invisible(NULL)
    if (verbose) {
      return(cli::cli_inform(...))
    } else {
      return(void(...))
    }
  }

  if (version == "99.9.9") {
    inform_if_verbose(c(
      "i" = "Skipping version check for development version.",
      ">" = "Please update using development mode."
    ))
    return(invisible(FALSE))
  }
  stable <- latest_available_version("stable")
  if (version > stable) {
    prerelease <- latest_available_version("prerelease")
    if (version < prerelease) {
      update <- TRUE
    } else {
      update <- FALSE
    }
    inform_if_verbose(
      c(
        "i" = "You are using prerelease version of Quarto: {version}.",
        if (update) {
          ">" = "A newer version is available: {prerelease}. You can download it from {.url https://quarto.org/docs/download/prerelease.html} or your preferred package manager if available."
        } else {
          "v" = "You are using the latest prerelease version."
        }
      )
    )
    return(invisible(update))
  } else if (version < stable) {
    inform_if_verbose(c(
      "i" = "You are using an older version of Quarto: {version}.",
      " " = "The latest stable version is: {stable}.",
      ">" = "You can download new version from https://quarto.org/docs/download/ or your preferred package manager if available."
    ))
    return(invisible(TRUE))
  } else {
    inform_if_verbose(c(
      "i" = "You are using the latest stable version of Quarto: {version}."
    ))
    return(invisible(FALSE))
  }
}


versions_urls <- list(
  stable = "https://quarto.org/docs/download/_download.json",
  prerelease = "https://quarto.org/docs/download/_prerelease.json"
)

get_json <- function(url) {
  jsonlite::fromJSON(url)
}

get_latest_info <- function(
  type = c("stable", "prerelease"),
  .call = rlang::caller_env()
) {
  type <- match.arg(type)
  res <- tryCatch(
    get_json(versions_urls[[type]]),
    error = function(e) {
      rlang::abort(
        "Failed to fetch latest versions: ",
        parent = e,
        call = .call
      )
      return(NULL)
    }
  )

  if (!is.null(res)) {
    return(res)
  }
}

default_infos <- function(type) {
  list(date = Sys.Date(), infos = get_latest_info(type))
}

latest_available_infos <- function(type = c("stable", "prerelease")) {
  type <- match.arg(type)
  type_name <- paste0("latest_", type)
  latest <- rlang::env_cache(
    the,
    type_name,
    default_infos(type)
  )
  # add a time check to invalidate the cache if the date is older than 1 day
  if (
    !is.null(latest$infos) &&
      !is.null(latest$date) &&
      latest$date > Sys.Date() - 1
  ) {
    return(latest$infos)
  } else {
    rlang::env_poke(
      the,
      type_name,
      default_infos(type)
    )
  }
}

latest_available_version <- function(type = c("stable", "prerelease")) {
  type <- match.arg(type)
  infos <- latest_available_infos(type)
  if (is.null(infos)) {
    return(NULL)
  }
  return(infos$version)
}


latest_available_published <- function(type = c("stable", "prerelease")) {
  type <- match.arg(type)
  infos <- latest_available_infos(type)
  if (is.null(infos)) {
    return(NULL)
  }
  return(infos$published)
}
