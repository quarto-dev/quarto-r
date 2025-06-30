# check_newer_version handles stable version scenarios

    Code
      check_newer_version("1.0.0")
    Message
      i You are using an older version of Quarto: 1.0.0.
        The latest stable version is: 1.5.3.
      > You can download new version from https://quarto.org/docs/download/ or your preferred package manager if available.

---

    Code
      check_newer_version("1.5.3")
    Message
      i You are using the latest stable version of Quarto: 1.5.3.

# check_newer_version handles prerelease version scenarios

    Code
      check_newer_version("1.6.3")
    Message
      i You are using prerelease version of Quarto: 1.6.3.
      A newer version is available: 1.6.4. You can download it from <https://quarto.org/docs/download/prerelease.html> or your preferred package manager if available.

---

    Code
      check_newer_version("1.6.5")
    Message
      i You are using prerelease version of Quarto: 1.6.5.
      You are using the latest prerelease version.

