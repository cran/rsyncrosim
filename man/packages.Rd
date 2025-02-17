% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/packages.R
\name{packages}
\alias{packages}
\alias{packages,character-method}
\alias{packages,missingOrNULL-method}
\alias{packages,Session-method}
\alias{packages,SsimLibrary-method}
\title{Installed or available packages}
\usage{
packages(ssimObject = NULL, installed = TRUE)

\S4method{packages}{character}(ssimObject = NULL, installed = TRUE)

\S4method{packages}{missingOrNULL}(ssimObject = NULL, installed = TRUE)

\S4method{packages}{Session}(ssimObject = NULL, installed = TRUE)

\S4method{packages}{SsimLibrary}(ssimObject)
}
\arguments{
\item{ssimObject}{\code{\link{Session}} or
\code{\link{SsimLibrary}} object. If \code{NULL} (default), \code{session()}
will be used}

\item{installed}{logical or character. \code{TRUE} (default) to list
installed packages or \code{FALSE} to list available packages on the server}
}
\value{
Returns a \code{data.frame} of packages installed or templates available
for a specified package.
}
\description{
Retrieves the packages installed or available in the current session if
called on a \code{\link{Session}} object, or the packages added to a
SyncroSim Library if called on a \code{\link{SsimLibrary}} object.
}
\examples{
\dontrun{
# Set the file path and name of the new SsimLibrary
myLibraryName <- file.path(tempdir(),"testlib")

# Set the SyncroSim Session and SsimLibrary
mySession <- session()
myLibrary <- ssimLibrary(name = myLibraryName, session = mySession)

# List all installed packages
packages(mySession)

# List all available packages on the server (including currently installed)
packages(installed = FALSE)
 
# Check the package(s) in your SsimLibrary
packages(myLibrary)
}

}
