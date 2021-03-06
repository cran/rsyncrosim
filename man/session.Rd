% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/session.R
\name{session}
\alias{session}
\alias{session,missingOrNULLOrChar-method}
\alias{session,SsimObject-method}
\title{Creates or returns a SyncroSim session.}
\usage{
session(x = NULL, silent = TRUE, printCmd = FALSE)

\S4method{session}{missingOrNULLOrChar}(x = NULL, silent = TRUE, printCmd = FALSE)

\S4method{session}{SsimObject}(x = NULL, silent = TRUE, printCmd = FALSE)
}
\arguments{
\item{x}{Character or SsimObject. An optional path to the SyncroSim installation.}

\item{silent}{Logical. Applies only if x is a path or NULL. If TRUE, warnings from the console are ignored. Otherwise they are printed.}

\item{printCmd}{Logical. Applies only if x is a path or NULL. If TRUE, arguments passed to the SyncroSim console are also printed. Helpful for debugging. FALSE by default.}
}
\value{
A SyncroSim Session object.
}
\description{
Methods to create or return a SyncroSim session.
}
\examples{
\donttest{
# Create Session
temp_dir <- tempdir()
mySession <- session()
myLibrary <- ssimLibrary(name = file.path(temp_dir,"testlib"), session = mySession)

filepath(mySession) # Lists the folder location of SyncroSim session
version(mySession) # Lists the version of SyncroSim session
package(mySession) # Dataframe of the packages installed with this version of SyncroSim
basePackage(mySession) # Dataframe of the base packages installed with this version of SyncroSim
}

}
