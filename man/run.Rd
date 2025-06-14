% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run.R
\name{run}
\alias{run}
\alias{run,character-method}
\alias{run,list-method}
\alias{run,SsimObject-method}
\title{Run scenarios}
\usage{
run(ssimObject, scenario = NULL, summary = FALSE, transformerName = NULL)

\S4method{run}{character}(ssimObject, scenario = NULL, summary = FALSE, transformerName = NULL)

\S4method{run}{list}(ssimObject, scenario = NULL, summary = FALSE, transformerName = NULL)

\S4method{run}{SsimObject}(ssimObject, scenario = NULL, summary = FALSE, transformerName = NULL)
}
\arguments{
\item{ssimObject}{\code{\link{SsimLibrary}}, \code{\link{Project}}, or
\code{\link{Scenario}} object, or a list of Scenarios, or character (i.e.
path to a SsimLibrary on disk)}

\item{scenario}{character, integer, or vector of these. Scenario names or ids.
If \code{NULL} (default), then runs all Scenarios associated with the SsimObject. Note
that integer ids are slightly faster}

\item{summary}{logical. If \code{FALSE} (default) result Scenario objects are returned.
If \code{TRUE} (faster) result Scenario ids are returned}

\item{transformerName}{character.  The name of the transformer to run (optional)}
}
\value{
If \code{summary = FALSE}, returns a result Scenario object or a named list
of result Scenarios. The name is the parent Scenario for each result. If
\code{summary = TRUE}, returns summary info for result Scenarios.
}
\description{
Run one or more SyncroSim \code{\link{Scenario}}(s).
}
\details{
Note that breakpoints are ignored unless the SsimObject is a single Scenario.
}
\examples{
\dontrun{
# Set the file path and name of the new SsimLibrary
myLibraryName <- "testlib"

# Set the SyncroSim Session, SsimLibrary, Project, and Scenario
myLibrary <- ssimLibrary(name = myLibraryName,
                         packages = "helloworldSpatial")
myProject <- project(myLibrary, project = "Definitions")
myScenario <- scenario(myProject, scenario = "My Scenario")
myScenario2 <- scenario(myProject, scenario = "My Scenario 2")

# Run with default parameters
resultScenario <- run(myScenario)

# Only return summary information
resultScenarioSummary <- run(myScenario, summary = TRUE)

# Run 2 scenarios at once
resultScenarios <- run(c(myScenario, myScenario2))
}

}
