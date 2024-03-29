% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/folder.R
\name{folder}
\alias{folder}
\title{Create or open a Folder}
\usage{
folder(ssimObject = NULL, folder = NULL, parentFolder = NULL, create = FALSE)
}
\arguments{
\item{ssimObject}{\code{\link{SsimLibrary}} or \code{\link{Project}} object.}

\item{folder}{character or integer. If character, then will either open an
existing folder if \code{create=FALSE}, or will create a new folder with the
given name if the folder does not exist yet or \code{create=TRUE} (Default).
If integer, will open the existing folder with the given folder ID (if the
ID exists).}

\item{parentFolder}{character, integer, or SyncroSim Folder object. If not
\code{NULL} (Default), the new folder will be created inside of the
specified parent folder}

\item{create}{logical. Whether to create a new folder if the folder name given
already exists in the SyncroSim library. If \code{FALSE} (Default), then will
return the existing folder with the given name. If \code{TRUE}, then will
return a new folder with the same name as an existing folder (but different
folder ID)}
}
\value{
A \code{Folder} object representing a SyncroSim folder.
}
\description{
Create or open a \code{\link{Folder}} from a SyncroSim
\code{\link{Project}}.
}
\examples{
\dontrun{
# Set the file path and name of the new SsimLibrary
myLibraryName <- file.path(tempdir(),"testlib")

# Set the SyncroSim Session, SsimLibrary, Project, and Scenario
mySession <- session()
myLibrary <- ssimLibrary(name = myLibraryName, session = mySession) 
myProject <- project(myLibrary, project = "My Project")
myScenario <- scenario(myProject, scenario = "My Scenario")

# Create a new folder
myFolder <- folder(myProject, folder = "New Folder")

# Create a nested folder within "New Folder"
myNestedFolder <- folder(myProject, folder = "New Nested Folder", 
                         parentFolder = myFolder)
}

}
