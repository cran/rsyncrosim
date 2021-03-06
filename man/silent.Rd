% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/silent.R
\name{silent}
\alias{silent}
\alias{silent,Session-method}
\alias{silent,missingOrNULLOrChar-method}
\title{Check if a Session is silent}
\usage{
silent(session)

\S4method{silent}{Session}(session)

\S4method{silent}{missingOrNULLOrChar}(session)
}
\arguments{
\item{session}{Session or character. A SyncroSim \code{\link{Session}} object or path to a session. If NULL, the default session will be used.}
}
\value{
Returns a logical value: `TRUE` if the session is silent and `FALSE` otherwise.
}
\description{
Checks whether a SyncroSim Session is silent or not.
}
