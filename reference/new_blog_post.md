# Create a new blog post

Creates (and potentially opens) the `index.qmd` file for a new blog
post.

## Usage

``` r
new_blog_post(
  title,
  dest = NULL,
  wd = NULL,
  open = rlang::is_interactive(),
  call = rlang::current_env(),
  ...
)
```

## Arguments

- title:

  A character string for the title of the post. It is converted to title
  case via
  [`tools::toTitleCase()`](https://rdrr.io/r/tools/toTitleCase.html).

- dest:

  A character string (or NULL) for the path within `posts`. By default,
  the title is adapted as the directory name.

- wd:

  An optional working directory. If `NULL`, the current working is used.

- open:

  A logical: have the default editor open a window to edit the
  `index.qmd` file?

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

- ...:

  A named list of values to be added to the yaml header, such as `date`,
  `author`, `categories`, `description`, etc. If no `date` is provided,
  the current date is used. If no `author` is provided,
  [`whoami::fullname()`](https://rdrr.io/pkg/whoami/man/fullname.html)
  is used to get the user's name.

## Value

The path to the index file.

## Examples
