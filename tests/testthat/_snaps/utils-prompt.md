# Checking non interactive approval

    Code
      expect_true(check_approval(TRUE, "My thing"))

---

    Code
      check_approval(FALSE, "My thing")
    Condition
      Error:
      ! My thing requires explicit approval.
      > Set `no_prompt = TRUE` if you agree.

---

    Code
      check_approval(FALSE, "My thing", see_more_at = "https://example.com")
    Condition
      Error:
      ! My thing requires explicit approval.
      > Set `no_prompt = TRUE` if you agree.
      i See more at <https://example.com>

# Checking interactive approval with prompt mocked n

    Code
      expect_false({
        check_approval(FALSE, "my-thing", see_more_at = "https://example.com")
      })
    Message
      i my-thing not approved

# Checking non interactive extension approval

    Code
      expect_true(check_extension_approval(TRUE, "My thing"))

---

    Code
      check_extension_approval(FALSE, "My thing")
    Condition
      Error in `check_extension_approval()`:
      ! My thing requires explicit approval.
      > Set `no_prompt = TRUE` if you agree.

---

    Code
      check_extension_approval(FALSE, "My thing", see_more_at = "https://example.com")
    Condition
      Error in `check_extension_approval()`:
      ! My thing requires explicit approval.
      > Set `no_prompt = TRUE` if you agree.
      i See more at <https://example.com>

# Checking interactive extension approval with prompt mocked y

    Code
      expect_true({
        check_extension_approval(FALSE, "my-thing")
      })
    Message
      my-thing may execute code when documents are rendered.
      * If you do not trust the author(s) of this my-thing, we recommend that you do not install or use this my-thing.

# Checking interactive extension approval with prompt mocked n

    Code
      expect_false({
        check_extension_approval(FALSE, "my-thing")
      })
    Message
      my-thing may execute code when documents are rendered.
      * If you do not trust the author(s) of this my-thing, we recommend that you do not install or use this my-thing.
      i my-thing not installed

# Checking non interactive removal approval

    Code
      expect_true(check_removal_approval(TRUE, "My thing"))

---

    Code
      check_removal_approval(FALSE, "My thing")
    Condition
      Error in `check_removal_approval()`:
      ! My thing requires explicit approval.
      > Set `no_prompt = TRUE` if you agree.

---

    Code
      check_removal_approval(FALSE, "My thing", see_more_at = "https://example.com")
    Condition
      Error in `check_removal_approval()`:
      ! My thing requires explicit approval.
      > Set `no_prompt = TRUE` if you agree.
      i See more at <https://example.com>

# Checking interactive removal approval with prompt mocked y

    Code
      expect_true({
        check_removal_approval(FALSE, "my-thing")
      })

# Checking interactive removal approval with prompt mocked n

    Code
      expect_false({
        check_removal_approval(FALSE, "my-thing")
      })
    Message
      i my-thing not removed

