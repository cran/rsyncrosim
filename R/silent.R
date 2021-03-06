# Copyright (c) 2019 Apex Resource Management Solution Ltd. (ApexRMS). All rights reserved.
# GPL v.3 License
#' @include AAAClassDefinitions.R
NULL

#' Check if a Session is silent
#'
#' Checks whether a SyncroSim Session is silent or not.
#'
#' @param session Session or character. A SyncroSim \code{\link{Session}} object or path to a session. If NULL, the default session will be used.
#' 
#' @return 
#' Returns a logical value: `TRUE` if the session is silent and `FALSE` otherwise.
#' 
#' @export
setGeneric("silent", function(session) standardGeneric("silent"))

#' @rdname silent
setMethod("silent", signature(session = "Session"), function(session) session@silent)

#' @rdname silent
setMethod("silent", signature(session = "missingOrNULLOrChar"), function(session) {
  if (class(session) == "character") {
    session <- .session(session)
  } else {
    session <- .session()
  }
  if ((class(session) == "character") && (session == SyncroSimNotFound(warn = FALSE))) {
    return(SyncroSimNotFound())
  }
  return(silent(session))
})

#' Set silent property of a Session
#'
#' Set silent property of a session to TRUE or FALSE
#'
#' @param session Session.
#' @param value Logical.
#' 
#' @return 
#' The updated ssimObject.
#' 
#' @export
setGeneric("silent<-", function(session, value) standardGeneric("silent<-"))
#' @rdname silent-set
setReplaceMethod(
  f = "silent",
  signature = "character",
  definition = function(session, value) {
    return(session)
  }
)

#' @rdname silent-set
setReplaceMethod(
  f = "silent",
  signature = "Session",
  definition = function(session, value) {
    session@silent <- value
    return(session)
  }
)
