% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/projectId.R
\name{projectId}
\alias{projectId}
\alias{projectId,character-method}
\alias{projectId,Project-method}
\alias{projectId,Scenario-method}
\alias{projectId,Folder-method}
\title{Retrieves projectId of SyncroSim Project, Scenario, or Folder}
\usage{
projectId(ssimObject)

\S4method{projectId}{character}(ssimObject)

\S4method{projectId}{Project}(ssimObject)

\S4method{projectId}{Scenario}(ssimObject)

\S4method{projectId}{Folder}(ssimObject)
}
\arguments{
\item{ssimObject}{\code{\link{Scenario}}, \code{\link{Project}}, or
\code{\link{Folder}} object}
}
\value{
An integer: project id.
}
\description{
Retrieves the projectId of a SyncroSim \code{\link{Project}},
\code{\link{Scenario}}, or \code{\link{Folder}}.
}
\examples{
\dontrun{
# Set the file path and name of the new SsimLibrary
myLibraryName <- file.path(tempdir(),"testlib")

# Set the SyncroSim Session, SsimLibrary, Project, and Scenario
mySession <- session()
myLibrary <- ssimLibrary(name = myLibraryName, session = mySession) 
myProject <- project(myLibrary, project = "Definitions")
myScenario <- scenario(myProject, scenario = "My Scenario")

# Get Project ID for SyncroSim Project and Scenario
projectId(myProject)
projectId(myScenario)
}

}
