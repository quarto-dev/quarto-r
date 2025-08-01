% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{yaml_quote_string}
\alias{yaml_quote_string}
\title{Add quoted attribute to strings for YAML output}
\usage{
yaml_quote_string(x)
}
\arguments{
\item{x}{A character vector or single string}
}
\value{
The input with quoted attributes applied
}
\description{
This function allows users to explicitly mark strings that should be quoted
in YAML output, giving full control over quoting behavior.
}
\details{
This is particularly useful for special values that might be misinterpreted
as \pkg{yaml} uses YAML 1.1 and Quarto expects YAML 1.2.

The \code{quoted} attribute is a convention used by \code{\link[yaml:as.yaml]{yaml::as.yaml()}}
}
\examples{
yaml::as.yaml(list(id = yaml_quote_string("1.0")))
yaml::as.yaml(list(id = "1.0"))

}
