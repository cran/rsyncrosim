# Copyright (c) 2019 Apex Resource Management Solution Ltd. (ApexRMS). All rights reserved.
# GPL v.3 License
#' @include AAAClassDefinitions.R
NULL

#' The scenarioId of a scenario.
#'
#' Retrieves the scenarioId of a Scenario.
#'
#' @param scenario Scenario.
#' 
#' @return 
#' Integer id of the input scenario.
#' 
#' @export
setGeneric("scenarioId", function(scenario) standardGeneric("scenarioId"))

#' @rdname scenarioId
setMethod("scenarioId", signature(scenario = "character"), function(scenario) {
  return(SyncroSimNotFound(scenario))
})

#' @rdname scenarioId
setMethod("scenarioId", signature(scenario = "Scenario"), function(scenario) {
  return(scenario@scenarioId)
})
