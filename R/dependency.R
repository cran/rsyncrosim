# Copyright (c) 2024 Apex Resource Management Solution Ltd. (ApexRMS). All rights reserved.
# MIT License
#' @include AAAClassDefinitions.R
NULL

#' Get, set or remove Scenario dependencies
#' 
#' List dependencies, set dependencies, or remove dependencies from a SyncroSim
#' \code{\link{Scenario}}. Setting dependencies is a way of linking together
#' Scenario Datafeeds, such that a change in the Scenario that is the source 
#' dependency will update the dependent Scenario as well. 
#'
#' @details
#'
#' If \code{dependency==NULL}, other arguments are ignored, and set of existing dependencies 
#' is returned in order of precedence (from highest to lowest precedence).
#' Otherwise, returns list of saved or error messages for each dependency of each 
#' scenario.
#' 
#' Note that pre-existing dependencies will be removed when adding new dependencies unless
#' those elements are included in the vector of new dependencies.
#'
#'
#' @param ssimObject \code{\link{Scenario}} object, character string, integer, or 
#' vector of these. The Scenario object, name, or ID to which a dependency is to 
#' be added (or has already been added if \code{remove=TRUE}). Note that integer ids 
#' are slightly faster.
#' 
#' @param value \code{\link{Scenario}} object, character string, integer, or 
#' vector of these. The Scenario object, name, or ID to be used as the 
#' dependency. If an empty vector is provided, all dependencies are removed. If 
#' multiple elements are provided, elements should be ordered from highest to lowest
#' precedence.
#' 
#' @return 
#' A data.frame: all dependencies for a given Scenario
#' 
#' @examples 
#' \dontrun{
#' # Specify file path and name of new SsimLibrary
#' myLibraryName <- file.path(tempdir(), "testlib")
#' 
#' # Set up a SyncroSim Session, SsimLibrary, Project, and 2 Scenarios
#' mySession <- session()
#' myLibrary <- ssimLibrary(name = myLibraryName, session = mySession)
#' myProject <- project(myLibrary, project = "Definitions")
#' myScenario <- scenario(myProject, scenario = "My Scenario")
#' myNewScenario <- scenario(myProject,
#'                           scenario = "my New Scenario")
#' 
#' # Set myScenario as a dependency of myNewScenario
#' dependency(myNewScenario) <- myScenario
#' 
#' # Get all dependencies info
#' dependency(myNewScenario)
#' 
#' # Remove all dependencies
#' dependency(myNewScenario) <- c()
#' }
#' 
#' @export
setGeneric("dependency", function(ssimObject) standardGeneric("dependency"))

#' @rdname dependency
setMethod("dependency", signature(ssimObject = "character"), function(ssimObject) {
  return(SyncroSimNotFound(ssimObject))
})

#' @rdname dependency
setMethod("dependency", signature(ssimObject = "Scenario"), function(ssimObject) {
  
  # Rename variable
  s <- ssimObject
  
  # get set of existing dependencies
  args <- list(list = NULL, dependencies = NULL, lib = .filepath(s), 
               sid = scenarioId(s), csv = NULL)
  tt <- command(args, .session(s))
  
  if (!grepl("Id,Name", tt[1], fixed = TRUE)) {
    stop(tt[1])
  }
  
  dependencySet <- .dataframeFromSSim(tt, localNames = FALSE)
  names(dependencySet)[names(dependencySet) == "Id"] <- "ScenarioId"
  
  return(dependencySet)
}
)

#' @rdname dependency
#' @export
setGeneric("dependency<-", function(ssimObject, value) standardGeneric("dependency<-"))

#' @rdname dependency
setReplaceMethod(
  f = "dependency",
  signature = "Scenario",
  definition = function(ssimObject, value) {
    
    # Parse value into string of dependency IDs, separated by a comma
    onlyRemoveDeps <- FALSE
    if (is.character(value) && length(value) == 1 && value == ""){
      onlyRemoveDeps <- TRUE
    } else if (length(value) == 0){
      onlyRemoveDeps <- TRUE
    }
    
    if (is(value, "Scenario")){
      value <- scenarioId(value)
    }
    
    valueList <- c()
    
    if (!onlyRemoveDeps){
      
      allScns <- .scenario(.ssimLibrary(ssimObject), summary = TRUE)
      
      for (v in value){
        if (is(v, "Scenario")) {
          valueList <- c(valueList, scenarioId(v))
        }
        
        else if (is(v, "character")) {
          cDep <- allScns$ScenarioId[allScns$Name == v]
          
          if (length(cDep) == 0) {
            stop("Could not find dependency scenario ", v)
          } else if (length(cDep) > 1) {
            stop("Found more than one scenario named ", v, 
                 ". Please specify a dependency scenario id:", 
                 paste0(v, collapse = ","))
          } else {
            valueList <- c(valueList, cDep)
          }
        } 
        
        else if (is(v, "numeric")) {
          if (!is.element(v, allScns$ScenarioId)) {
            stop(v, ": dependency scenario not found in library.")
          }
          valueList <- c(valueList, v)
        }
      }
    }
    
    valueList <- paste(valueList, collapse = ",")
    
    # Remove all existing dependencies
    tt <- command(list(remove = NULL, dependency = NULL, lib = .filepath(ssimObject), 
                       sid = .scenarioId(ssimObject), all = NULL, force = NULL), 
                  .session(ssimObject))
    
    if (!identical(tt[1], "saved")) {
      stop(tt)
    }
    
    if (!onlyRemoveDeps) {
      # Add all new dependencies, with priority being the same order they were input
      args <- list(add = NULL, dependency = NULL, lib = .filepath(ssimObject),
                   sid = .scenarioId(ssimObject))
      
      # TODO: parse value depending on what the input format is
      if (length(value) == 1) {
        args <- append(args, list(did = valueList))
      } else {
        args <- append(args, list(dids = valueList))
      }
      
      tt <- command(args, .session(ssimObject))
      
      if (!identical(tt[1], "saved")) {
        stop(tt)
      }
    }
    
    return(ssimObject)
  }
)
