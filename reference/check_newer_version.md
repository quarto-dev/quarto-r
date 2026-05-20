# Check for newer version of Quarto

Checks if a newer version of Quarto is available and informs the user
about their current version status. The function compares the current
Quarto version against the latest stable and prerelease versions
available online.

## Usage

``` r
check_newer_version(version = quarto_version(), verbose = TRUE)
```

## Arguments

- version:

  Character string specifying the Quarto version to check. Defaults to
  the currently installed version detected by
  [`quarto_version()`](https://quarto-dev.github.io/quarto-r/reference/quarto_version.md).
  Use "99.9.9" to indicate a development version.

- verbose:

  Logical indicating whether to print informational messages. Defaults
  to `TRUE`. When `FALSE`, the function runs silently and only returns
  the logical result.

## Value

Invisibly returns a logical value:

- `TRUE` if an update is available

- `FALSE` if no update is needed or when using development version The
  function is primarily called for its side effects of printing
  informational messages (when `verbose = TRUE`).

## Details

The function handles three scenarios:

- **Development version** (99.9.9): Skips version check with
  informational message

- **Prerelease version**: Compares against latest prerelease and informs
  about updates

- **Stable version**: Compares against latest stable version and
  suggests updates if needed

Version information is fetched from Quarto's download JSON endpoints and
cached in current session for up to 24 hours to avoid repeated network
requests.

## Network Requirements

This function requires an internet connection to fetch the latest
version information from quarto.org. If the network request fails, an
error will be thrown.

## See also

[`quarto_version()`](https://quarto-dev.github.io/quarto-r/reference/quarto_version.md)
for getting the current Quarto version,

## Examples

``` r
# Check current Quarto version
check_newer_version()
#> ℹ You are using prerelease version of Quarto: 1.10.3.
#> You are using the latest prerelease version.

# Check a specific version
check_newer_version("1.7.30")
#> ℹ You are using an older version of Quarto: 1.7.30.
#>   The latest stable version is: 1.9.37.
#> → You can download new version from https://quarto.org/docs/download/ or your
#>   preferred package manager if available.

# Check development version (will skip check)
check_newer_version("99.9.9")
#> ℹ Skipping version check for development version.
#> → Please update using development mode.

# Check silently without messages
result <- check_newer_version(verbose = FALSE)
if (result) {
  message("Update available!")
}
```
