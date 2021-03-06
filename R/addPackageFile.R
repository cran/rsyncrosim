# Copyright (c) 2019 Apex Resource Management Solution Ltd. (ApexRMS). All rights reserved.
# GPL v.3 License
#' @include AAAClassDefinitions.R
NULL

#' Adds a package to SyncroSim
#'
#' Adds a package to SyncroSim from a package file.
#'
#' @param filename Character string.  The path to a SyncroSim package file.
#' @param session Session.
#' 
#' @return 
#' This function invisibly returns `TRUE` upon success (i.e.successful 
#' install) and `FALSE` upon failure.
#' 
#' @export
setGeneric("addPackageFile", function(filename, session = NULL) standardGeneric("addPackageFile"))

#' @rdname addPackageFile
setMethod("addPackageFile", signature(session = "character"), function(filename, session) {
  return(SyncroSimNotFound(session))
})

#' @rdname addPackageFile
setMethod("addPackageFile", signature(session = "missingOrNULL"), function(filename, session) {
  session <- .session()
  return(addPackageFile(filename, session))
})

#' @rdname addPackageFile
setMethod("addPackageFile", signature(session = "Session"), function(filename, session) {
  success <- FALSE
  
  if (is.null(filename)) {
    stop("A file name is required")
  }
  
  if (!file.exists(filename)) {
    tt <- paste0("Cannot find file: ", filename)
  } else{
    tt <- command(args = list(finstall = filename), session, program = "SyncroSim.PackageManager.exe")
    if (tt == "saved"){
      success <- TRUE
      tt <- paste0("Package installed from file <", filename, ">")
    }
  }
  message(tt)
  return(invisible(success))
})
