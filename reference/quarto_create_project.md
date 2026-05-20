# Create a quarto project

This function calls `quarto create project <type> <name>`. It creates a
new directory with the project name, inside the requested parent
directory, and adds some starter files that are appropriate to the
project type.

## Usage

``` r
quarto_create_project(
  name,
  type = "default",
  dir = ".",
  title = name,
  no_prompt = FALSE,
  quiet = FALSE,
  quarto_args = NULL
)
```

## Arguments

- name:

  The name of the project and the directory that will be created.
  Special case is to use `name = "."` to create the project in the
  current directory. In that case provide `title` to set the project
  title.

- type:

  The type of project to create. As of Quarto 1.4, it can be one of
  `default`, `website`, `blog`, `book`, `manuscript`, `confluence`.

- dir:

  The directory in which to create the new Quarto project, i.e. the
  parent directory.

- title:

  The title of the project. By default, it will be the name of the
  project, same as directory name created. or "My project" if
  `name = "."`. If you want to set a different title, provide it here.

- no_prompt:

  Do not prompt to approve the creation of the new project folder.

- quiet:

  Suppress warning and other messages, from R and also Quarto CLI (i.e
  `--quiet` is passed as command line).

  `quarto.quiet` R option or `R_QUARTO_QUIET` environment variable can
  be used to globally override a function call (This can be useful to
  debug tool that calls `quarto_*` functions directly).

  On Github Actions, it will always be `quiet = FALSE`.

- quarto_args:

  Character vector of other `quarto` CLI arguments to append to the
  Quarto command executed by this function. This is mainly intended for
  advanced usage and useful for CLI arguments which are not yet mirrored
  in a dedicated parameter of this R function. See
  `quarto render --help` for options.

## Quarto version required

This function requires Quarto 1.4 or higher. Use
[`quarto_version()`](https://quarto-dev.github.io/quarto-r/reference/quarto_version.md)
to see your current Quarto version.

## See also

Quarto documentation on [Quarto
projects](https://quarto.org/docs/projects/quarto-projects.html)

## Examples

``` r
if (FALSE) { # \dontrun{
# Create a new project directory in another directory
quarto_create_project("my-first-quarto-project", dir = "~/tmp")

# Create a new project directory in the current directory
quarto_create_project("my-first-quarto-project")

# Create a new project with a different title
quarto_create_project("my-first-quarto-project", title = "My Quarto Project")

# Create a new project inside the current directory directly
quarto_create_project(".", title = "My Quarto Project")
} # }

```
