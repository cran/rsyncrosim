# Copyright (c) 2019 Apex Resource Management Solution Ltd. (ApexRMS). All rights reserved.
# GPL v.3 License
#' @include AAAClassDefinitions.R
NULL

#' Run scenarios
#'
#' Run one or more SyncroSim scenarios.
#'
#' @details
#' Note that breakpoints are ignored unless ssimObject is a single scenario.
#'
#' @param ssimObject SsimLibrary/Project/Scenario or a list of Scenarios. Or the path to a library on disk.
#' @param scenario Character, integer, or vector of these. Scenario names or ids. Or NULL. Note that integer ids are slightly faster.
#' @param summary Logical. If FALSE (default) result Scenario objects are returned. If TRUE (faster) result scenario ids are returned.
#' @param jobs Integer. The number of jobs to run. Passed to SyncroSim where multithreading is handled.
#' @param transformerName Character.  The name of the transformer to run.
#' @param forceElements Logical. If TRUE then returns a single result scenario as a named list; otherwise returns a single result scenario as a Scenario object. Applies only when summary=FALSE.
#' 
#' @return 
#' If \code{summary = FALSE}, returns a result Scenario object or a named list of result Scenarios. 
#' The name is the parent scenario for each result. If \code{summary = TRUE}, returns summary info 
#' for result scenarios.
#' 
#' @export
setGeneric("run", function(ssimObject, scenario = NULL, summary = FALSE, jobs = 1, transformerName = NULL, forceElements = FALSE) standardGeneric("run"))

#' @rdname run
setMethod("run", signature(ssimObject = "character"), function(ssimObject, scenario, summary, jobs, transformerName, forceElements) {
  if (ssimObject == SyncroSimNotFound(warn = FALSE)) {
    return(SyncroSimNotFound())
  }
  ssimObject <- .ssimLibrary(ssimObject)
  out <- run(ssimObject, scenario, summary, jobs, transformerName, forceElements)
  return(out)
})

#' @rdname run
setMethod("run", signature(ssimObject = "list"), function(ssimObject, scenario, summary, jobs, transformerName, forceElements) {
  x <- getIdsFromListOfObjects(ssimObject, expecting = "Scenario", scenario = scenario)
  ssimObject <- x$ssimObject
  scenario <- x$objs
  out <- run(ssimObject, scenario, summary, jobs, transformerName, forceElements)
  return(out)
})

#' @rdname run
setMethod("run", signature(ssimObject = "SsimObject"), function(ssimObject, scenario, summary, jobs, transformerName, forceElements) {
  xProjScn <- .getFromXProjScn(ssimObject, scenario = scenario, convertObject = TRUE, returnIds = TRUE, goal = "scenario", complainIfMissing = TRUE)
  # Now assume scenario is x is valid object and scenario is valid vector of scenario ids
  x <- xProjScn$ssimObject
  scenario <- xProjScn$scenario
  scenarioSet <- xProjScn$scenarioSet

  if (!is.numeric(scenario)) {
    stop("Error in run(): expecting valid scenario ids.")
  }

  out <- list()
  addBits <- seq(1, length(scenario))
  for (i in seq(length.out = length(scenario))) {
    tt <- NULL
    cScn <- scenario[i]
    name <- scenarioSet$name[scenarioSet$scenarioId == cScn][1]
    resultId <- NA

    print(paste0("Running scenario [", cScn, "] ", name))

    if (class(ssimObject) == "Scenario") {
      breakpoints <- ssimObject@breakpoints
      xsim <- ssimObject
      xsim@breakpoints <- breakpoints
    } else {
      breakpoints <- NULL
    }

    if ((class(breakpoints) != "list") | (length(breakpoints) == 0)) {
      args <- list(run = NULL, lib = .filepath(x), sid = cScn, jobs = jobs)

      if (!is.null(transformerName)) {
        args[["trx"]] <- transformerName
      }

      tt <- command(args, .session(x))

      for (i in tt) {
        if (startsWith(i, "Result scenario ID is:")) {
          resultId <- strsplit(i, ": ", fixed = TRUE)[[1]][2]
        } else {
          print(i)
        }
      }

      if (is.na(resultId)) {
        stop()
      }
    } else {

      # create a session
      xsim@breakpoints <- breakpoints
      cBreakpointSession <- breakpointSession(xsim)
      # TO DO: multiple tries in connection

      # load a library
      msg <- paste0('load-library --lib=\"', filepath(x), '\"')
      ret <- remoteCall(cBreakpointSession, msg)
      if (ret != "NONE") {
        stop("Something is wrong: ", ret)
      }

      # set breakpoints
      ret <- setBreakpoints(cBreakpointSession)
      if (ret != "NONE") {
        stop("Something is wrong: ", ret)
      }

      resultId <- run(cBreakpointSession, jobs = jobs)
      resp <- writeLines("shutdown", connection(cBreakpointSession), sep = "")
      close(connection(cBreakpointSession)) # Close the connection.
    }
    inScn <- paste0(name, " (", cScn, ")")

    if (is.element(inScn, names(out))) {
      inScn <- paste(inScn, addBits[i])
    }
    if (!identical(resultId, suppressWarnings(as.character(as.numeric(resultId))))) {
      out[[inScn]] <- tt
      print(tt)
    } else {
      if (summary) {
        out[[inScn]] <- as.numeric(resultId)
        scn <- .scenario(x, scenario = as.numeric(resultId))
      } else {
        out[[inScn]] <- .scenario(x, scenario = as.numeric(resultId))
      }
    }
  }

  if (summary && (class(out) == "list")) {
    # summary info for ids
    scnSelect <- unlist(out)
    out <- .scenario(x, scenario = scnSelect, summary = TRUE)
  }

  if (!forceElements && (class(out) == "list") && (length(out) == 1)) {
    out <- out[[1]]
  }
  return(out)
})

#' @rdname run
setMethod("run", signature(ssimObject = "BreakpointSession"), function(ssimObject, scenario, summary, jobs, forceElements) {
  x <- ssimObject
  l <- ssimLibrary(name = x@scenario@filepath, session = x@scenario@session)
  msg <- paste0("create-result --sid=", .scenarioId(x@scenario))
  ret <- remoteCall(x, msg)
  breaks <- x@scenario@breakpoints
  newScn <- .scenario(l, scenario = as.numeric(ret))
  newScn@breakpoints <- breaks
  x@scenario <- newScn

  if (jobs == 1) {
    msg <- paste0("run-scenario --sid=", .scenarioId(x@scenario), " --jobs=1")
    ret <- tryCatch(
      {
        remoteCall(x, msg)
      },
      warning = function(w) {
        print(w)
      },
      error = function(e) {
        resp <- writeLines("shutdown", connection(x), sep = "")
        close(connection(x))
        stop(e)
      }
    )
    return(ret)
  } else {
    msg <- paste0("split-scenario --sid=", .scenarioId(x@scenario), " --jobs=", jobs)

    tt <- tryCatch(
      {
        remoteCall(x, msg)
      },
      warning = function(w) {
        print(w)
      },
      error = function(e) {
        resp <- writeLines("shutdown", connection(x), sep = "")
        close(connection(x))
        stop(e)
      }
    )

    tempPath <- paste0(filepath(x@scenario), ".temp/Scenario-", .scenarioId(x@scenario), "/SSimJobs")
    tempFiles <- list.files(tempPath, include.dirs = FALSE)
    tempFiles <- tempFiles[grepl(".ssim", tempFiles, fixed = TRUE) & !grepl(".ssim.input", tempFiles, fixed = TRUE) & !grepl(".ssim.output", tempFiles, fixed = TRUE)]
    if (length(tempFiles) <= 1) {
      resp <- writeLines("shutdown", connection(x), sep = "")
      close(connection(x))
      stop("Problem with split-scenario: only one job was created. This is known problem caused by dependencies that has not yet been fixed.")
    } else {
      jobs <- length(tempFiles)
    }

    files <- paste0(filepath(x@scenario), ".temp/Scenario-", .scenarioId(x@scenario), "/SSimJobs/Job-", seq(1:jobs), ".ssim")
    port <- as.numeric(strsplit(summary(x@connection)[[1]], ":")[[1]][2])
    ports <- port + seq(1, jobs)
    # make list of arguments for parLapply()
    args <- list()
    for (i in 1:length(files)) {
      args[[i]] <- list(x = files[i], session = session(x@scenario), port = ports[i], breaks = x@scenario@breakpoints)
    }

    # Following https://www.win-vector.com/blog/2016/01/parallel-computing-in-r/
    LogFileName <- paste0(dirname(filepath(x@scenario)), "/parallelLog.txt")
    if (file.exists(LogFileName)) file.remove(LogFileName)

    parallelCluster <- parallel::makeCluster(jobs, outfile = LogFileName)
    parallel::clusterEvalQ(parallelCluster, library(rsyncrosim))

    # TO DO: catch error messages properly in parallel processing...
    ret <- tryCatch(
      {
        parallel::parLapply(parallelCluster, args, runJobParallel)
      },
      warning = function(w) {
        print(tt)
        print(w)
      },
      error = function(e) {
        print(tt)
        resp <- writeLines("shutdown", connection(x), sep = "")
        close(connection(x))
        stop(e)
      }
    )

    # Shutdown cluster neatly
    if (!is.null(parallelCluster)) {
      parallel::stopCluster(parallelCluster)
      parallelCluster <- c()
    }

    msg <- paste0("merge-scenario --sid=", .scenarioId(x@scenario))
    ret <- tryCatch(
      {
        remoteCall(x, msg)
      },
      warning = function(w) {
        print(w)
      },
      error = function(e) {
        resp <- writeLines("shutdown", connection(x), sep = "")
        close(connection(x))
        stop(e)
      }
    )

    # remove temporary directory
    unlink(paste0(filepath(x@scenario), ".temp/Scenario-", .scenarioId(x@scenario)), recursive = TRUE)

    return(ret)
  }
})
