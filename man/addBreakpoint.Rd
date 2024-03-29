% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/breakpoint.R
\name{addBreakpoint}
\alias{addBreakpoint}
\alias{addBreakpoint,Scenario-method}
\title{Add a Scenario breakpoint}
\usage{
addBreakpoint(x, transformerName, breakpointType, arguments, callback)

\S4method{addBreakpoint}{Scenario}(x, transformerName, breakpointType, arguments, callback)
}
\arguments{
\item{x}{\code{\link{Scenario}} object}

\item{transformerName}{character. A Stochastic Time Transformer
e.g. "stsim_Runtime" (optional)}

\item{breakpointType}{character. Options include "bi" (before iteration),
"ai" (after iteration), "bt" (before timestep), or "at" (after timestep)
(optional)}

\item{arguments}{vector of timesteps or iterations e.g. c(1,2) (optional)}

\item{callback}{function to be called when the breakpoint is hit (optional)}
}
\value{
A SyncroSim Scenario with an updated list of breakpoints.
}
\description{
This function allows the user to add breakpoints to a SyncroSim model, for a
given \code{\link{Scenario}}. When the Scenario is \code{\link{run}} the
function specified by the callback argument will be called for the specified
iterations or timesteps.
}
\details{
Breakpoints are only supported for Stochastic Time Transformers.
}
\examples{
\dontrun{
# Create callback function
callbackFunction <- function(x, iteration, timestep) {
  print(paste0("Breakpoint hit: ", scenarioId(x)))
}

# Install helloworldSpatial package
addPackage("helloworldSpatial")

# Set SsimLibrary name
myLibraryName <- file.path(tempdir(),"testlib")

# Set Session and SsimLibrary
mySession <- session()
myLibrary <- ssimLibrary(name = myLibraryName,
                         session = mySession,
                         package = "helloworldSpatial")
myScenario <- scenario(myLibrary, "My Scenario")

# Add breakpoints before the 1st and 2nd iterations
myScenario <- addBreakpoint(x= myScenario,
                            transformerName= "helloworldSpatial_Primary",
                            breakpointType = "bi", 
                            arguments = c(1,2),
                            callback = callbackFunction)
                            
# Check that the breakpoints were added
breakpoint(myScenario)
}
}
