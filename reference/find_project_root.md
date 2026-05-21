# Find the root of a Quarto project

This function checks if the current working directory is within a Quarto
project by looking for Quarto project files (`_quarto.yml` or
`_quarto.yaml`). Unlike
[`get_running_project_root()`](https://quarto-dev.github.io/quarto-r/reference/get_running_project_root.md),
this works both during rendering and interactive sessions.

## Usage

``` r
find_project_root(path = ".")
```

## Arguments

- path:

  Character. Path to check for Quarto project files. Defaults to current
  working directory.

## Value

Character Path of the project root directory if found, or `NULL`

## See also

[`get_running_project_root()`](https://quarto-dev.github.io/quarto-r/reference/get_running_project_root.md)
for detecting active Quarto rendering

## Examples

``` r
tmpdir <- tempfile()
dir.create(tmpdir)
find_project_root(tmpdir)
#> NULL
quarto_create_project("test-proj", type = "blog", dir = tmpdir, no_prompt = TRUE, quiet = TRUE)
blog_post_dir <- file.path(tmpdir, "test-proj", "posts", "welcome")
find_project_root(blog_post_dir)
#> [1] "/tmp/RtmpyUxhgY/file1d5c61261426/test-proj"

xfun::in_dir(blog_post_dir, {
  # Check if current directory is a Quarto project or in one
  !is.null(find_project_root())
})
#> [1] TRUE

# clean up
unlink(tmpdir, recursive = TRUE)
```
