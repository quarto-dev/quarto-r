% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/inspect.R
\name{quarto_inspect}
\alias{quarto_inspect}
\title{Inspect Quarto Input File or Project}
\usage{
quarto_inspect(input = ".")
}
\arguments{
\item{input}{The input file or project directory to inspect.}
}
\value{
Named list. For input files, the list has members engine, format,
and resources. For projects the list has members engines and config
}
\description{
Inspect a Quarto project or input path. Inspecting a project returns its
config and engines. Inspecting an input path return its formats, engine,
and dependent resources.
}
\examples{
\dontrun{
# Inspect input file file
quarto_inspect("notebook.Rmd")

# Inspect project
quarto_inspect("myproject")
}

}
