% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/disableAddon.R
\name{disableAddon}
\alias{disableAddon}
\alias{disableAddon,character-method}
\alias{disableAddon,SsimLibrary-method}
\title{Disable addon package(s)}
\usage{
disableAddon(ssimLibrary, name)

\S4method{disableAddon}{character}(ssimLibrary, name)

\S4method{disableAddon}{SsimLibrary}(ssimLibrary, name)
}
\arguments{
\item{ssimLibrary}{\code{\link{SsimLibrary}} object}

\item{name}{character string or vector of addon name(s)}
}
\value{
This function invisibly returns \code{TRUE} upon success (i.e.successful deactivation
of the addon) or \code{FALSE} upon failure.
}
\description{
Disable \code{\link{addon}} package(s) of a \code{\link{SsimLibrary}}.
}
\examples{
\dontrun{
# Install "stsim" SyncroSim package
addPackage("stsim")

# Specify file path and name of new SsimLibrary
myLibraryName <- file.path(tempdir(), "testlib")

# Set up a SyncroSim Session, SsimLibrary, and Project
mySession <- session()
myLibrary <- ssimLibrary(name = myLibraryName, session = mySession, 
                         package = "stsim")

# Enable addon package
enableAddon(myLibrary, c("stsimsf"))
addon(myLibrary)

# Disable addon package
disableAddon(myLibrary, c("stsimsf"))
addon(myLibrary)
}

}
\seealso{
\code{\link{addon}}
}
