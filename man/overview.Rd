% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/methods-Matched.R
\name{overview}
\alias{overview}
\alias{overview,Matched,numeric_OR_missing-method}
\title{Overview of matching quality}
\usage{
overview(x, digits = 2, ...)

\S4method{overview}{Matched,numeric_OR_missing}(x, digits)
}
\arguments{
\item{x}{Matched object}

\item{digits}{Integer indicating the number
of significant digits to be used. Negative
values are allowed (see \code{?signif}).}

\item{...}{Additional arguments.}
}
\value{
\itemize{
\item A printed overview of matching quality.
\item (Internally) a \code{MatchedOverview} object.
}
}
\description{
The overview function provides a quick assessment of
overall matching quality by reporting the N, mean, and
s.d. of focal, matched, pool, and unmatched sets for all
covariates as well as the propensity scores ('ps').
The mean and s.d. difference in focal - matched is also
reported.
}
\details{
Factor, character, or logical covariates are reported by
N per set, rather than with mean and s.d.
}
\examples{
set.seed(123)
mdf <- makeExampleMatchedDataSet(matched = TRUE)
overview(mdf)

}
