# Copyright (c) 2024 Apex Resource Management Solution Ltd. (ApexRMS). All rights reserved.
# MIT License
#' @include AAAClassDefinitions.R
NULL

#' Run scenarios
#'
#' Run one or more SyncroSim \code{\link{Scenario}}(s).
#'
#' @param ssimObject \code{\link{SsimLibrary}}, \code{\link{Project}}, or
#'     \code{\link{Scenario}} object, or a list of Scenarios, or character (i.e.
#'     path to a SsimLibrary on disk)
#' @param scenario character, integer, or vector of these. Scenario names or ids. 
#'     If \code{NULL} (default), then runs all Scenarios associated with the SsimObject. Note 
#'     that integer ids are slightly faster
#' @param summary logical. If \code{FALSE} (default) result Scenario objects are returned. 
#'     If \code{TRUE} (faster) result Scenario ids are returned
#' @param transformerName character.  The name of the transformer to run (optional)
#'     
#' @details
#' Note that breakpoints are ignored unless the SsimObject is a single Scenario.
#' 
#' @return 
#' If \code{summary = FALSE}, returns a result Scenario object or a named list 
#' of result Scenarios. The name is the parent Scenario for each result. If 
#' \code{summary = TRUE}, returns summary info for result Scenarios.
#' 
#' @examples 
#' \dontrun{
#' # Set the file path and name of the new SsimLibrary
#' myLibraryName <- "testlib"
#' 
#' # Set the SyncroSim Session, SsimLibrary, Project, and Scenario
#' myLibrary <- ssimLibrary(name = myLibraryName,
#'                          packages = "helloworldSpatial")
#' myProject <- project(myLibrary, project = "Definitions")
#' myScenario <- scenario(myProject, scenario = "My Scenario")
#' myScenario2 <- scenario(myProject, scenario = "My Scenario 2")
#' 
#' # Run with default parameters
#' resultScenario <- run(myScenario)
#' 
#' # Only return summary information
#' resultScenarioSummary <- run(myScenario, summary = TRUE)
#' 
#' # Run 2 scenarios at once
#' resultScenarios <- run(c(myScenario, myScenario2))
#' }
#' 
#' @export
setGeneric("run", 
           function(ssimObject, scenario = NULL, summary = FALSE, 
                    transformerName = NULL) standardGeneric("run"))

#' @rdname run
setMethod("run", signature(ssimObject = "character"), 
          function(ssimObject, scenario, summary, transformerName) {
            
  if (ssimObject == SyncroSimNotFound(warn = FALSE)) {
    return(SyncroSimNotFound())
  }
            
  ssimObject <- .ssimLibrary(ssimObject)
  out <- run(ssimObject, scenario, summary, transformerName)
  
  return(out)
})

#' @rdname run
setMethod("run", signature(ssimObject = "list"), 
          function(ssimObject, scenario, summary, transformerName) {
            
  x <- getIdsFromListOfObjects(ssimObject, expecting = "Scenario", 
                               scenario = scenario)
  ssimObject <- x$ssimObject
  scenario <- x$objs
  out <- run(ssimObject, scenario, summary, transformerName)
  
  return(out)
})

#' @rdname run
setMethod("run", signature(ssimObject = "SsimObject"), 
          function(ssimObject, scenario, summary, transformerName) {
  
  ScenarioId <- NULL     
  xProjScn <- .getFromXProjScn(ssimObject, scenario = scenario, 
                               convertObject = TRUE, returnIds = TRUE, 
                               goal = "scenario", complainIfMissing = TRUE)
  
  # Now assume scenario is x is valid object and scenario is valid vector of scenario ids
  x <- xProjScn$ssimObject
  scenario <- xProjScn$scenario
  scenarioSet <- xProjScn$scenarioSet
  originalScns <- .scenario(.project(x, project = xProjScn$project))

  if (!is.numeric(scenario)) {
    stop("Error in run(): expecting valid scenario ids.")
  }
  
  for (i in seq(length.out = length(scenario))) {

    cScn <- scenario[i]
    name <- scenarioSet$Name[scenarioSet$ScenarioId == cScn][1]

    print(paste0("Running scenario [", cScn, "] ", name))

    args <- list(run = NULL, lib = .filepath(x), sid = cScn)

    if (!is.null(transformerName)) {
      args[["trx"]] <- transformerName
    }

    tt <- command(args, .session(x))
    
    if (grepl("You must be signed in", tt[1]) | grepl("There has been an issue with your SyncroSim license file", tt[1])) {
      msg <- paste(tt[1], 
                   "\r\n",
                   "\r\n",
                   " Use the signIn() function to sign in to your SyncroSim",
                   "account from rsyncrosim.")
      stop(msg)
    }

    if (tt[1] != "saved") {
      message(tt)
    }
  }
  
  finalScns <- .scenario(.project(x, project = xProjScn$project))
  newScnIds <- setdiff(finalScns$ScenarioId, originalScns$ScenarioId)
  
  if (summary == TRUE){
    out <- subset(finalScns, subset = ScenarioId %in% newScnIds)
  } else {
    if (length(newScnIds) > 1){
      out <- list()
      for (scnId in newScnIds){
        out <- append(out, .scenario(x, scenario = scnId))
      }
    } else {
      out <- .scenario(x, scenario = newScnIds)
    }
  }
  
  return(out)
})
