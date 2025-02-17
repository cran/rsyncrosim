# Copyright (c) 2024 Apex Resource Management Solution Ltd. (ApexRMS). All rights reserved.
# MIT License
#' @include AAAClassDefinitions.R
NULL

SyncroSimNotFound <- function(inMessage = NULL, warn = TRUE) {
  outMessage <- "SyncroSim not found."
  if (!is.null(inMessage)) {
    if (inMessage != outMessage) {
      stop(inMessage)
    }
  }
  if (warn) {
    warning(outMessage)
  }
  return(outMessage)
}

backupEnabled <- function(path) {
  drv <- DBI::dbDriver("SQLite")
  con <- DBI::dbConnect(drv, path)

  tableExists <- DBI::dbExistsTable(con, "core_Backup")
  
  # Check for existence of table, if it does not exist assume we want to 
  # go ahead with the backup
  if(tableExists){
    ret <- DBI::dbGetQuery(con, "SELECT * FROM core_Backup")
    DBI::dbDisconnect(con)
  } else{
    DBI::dbDisconnect(con)
    return(TRUE)
  }

  if (is.na(ret$BeforeUpdate)) {
    return(FALSE)
  }

  if (ret$BeforeUpdate == 0) {
    return(FALSE)
  }

  return(TRUE)
}

deleteDatasheet <- function(x, datasheet, datasheets, cProj = NULL, cScn = NULL, 
                            cProjName = NULL, cScnName = NULL, out = list(), 
                            force) {
  out <- list()
  lib = ssimLibrary(.filepath(x), summary=T)
  
  for (j in seq(length.out = length(datasheet))) {
    cName <- datasheet[j]
    
    if (!grepl("_", cName, fixed = TRUE)) {
      stop("The datasheet name requires a package prefix (e.g., 'stsim_RunControl')")
    }
    
    cSheet <- subset(datasheets, name == cName)
    if (nrow(cSheet) == 0) {
      stop("datasheet ", cName, " not found in object identified by ssimObject/project/scenario arguments.")
    }
    targs <- list(delete = NULL, data = NULL, lib = .filepath(x), sheet = cName, force = NULL)
    outName <- cName
    if (cSheet$scope == "project") {
      targs[["pid"]] <- cProj
      outName <- paste0(outName, " pid", cProj)
      addPrompt <- paste0(" from project ", cProjName, "(", cProj, ")")
    }
    if (cSheet$scope == "scenario") {
      targs[["sid"]] <- cScn
      outName <- paste0(outName, " sid", cScn)
      addPrompt <- paste0(" from scenario ", cScnName, "(", cScn, ")")
    }

    if (force) {
      answer <- "y"
    } else {
      promptString <- paste0("Do you really want to delete datasheet ", cName, addPrompt, "? (y/n): ")
      answer <- readline(prompt = promptString)
    }
    if (!is.element(outName, names(out))) { # don't try something again that has already been tried
      if (answer == "y") {
        outBit <- command(targs, .session(x))
      } else {
        outBit <- "skipped"
      }
      out[[outName]] <- outBit
    }
  }
  if (length(out) == 1) {
    out <- out[[1]]
  }
  return(out)
}

deleteProjectDatasheet <- function(x, datasheet, project, allProjects,
                                   out = list(), force){
  
  if (is.element(class(x), c("Project", "Scenario"))) {
    datasheets <- .datasheets(x, refresh = TRUE)
  } else {
    datasheets <- .datasheets(.project(x, project = project[1]))
  }
  
  out <- list()
  for (i in seq(length.out = length(project))) {
    
    cProj <- project[i]
    name <- allProjects$name[allProjects$projectId == cProj]
    outBit <- deleteDatasheet(x, datasheet, datasheets, cProj = cProj, 
                              cScn = NULL, cProjName = name, cScnName = NULL, 
                              out = out, force = force)
    
    if (outBit == "saved"){ 
      message(paste0("Datasheet " , datasheet, " deleted"))
      outBit <- TRUE
    } else{
      message(outBit)
      outBit <- FALSE
    }
    
    out[[as.character(cProj)]] <- outBit
  }
  
  if (length(out) == 1) {
    out <- out[[1]]
  }
  
  return(out)
}

deleteProject <- function(x, project, allProjects, out = list(), force){
  
  out <- list()
  for (i in seq(length.out = length(project))) {
    cProj <- project[i]
    name <- allProjects$name[allProjects$projectId == cProj]
    
    if (force) {
      answer <- "y"
    } else {
      answer <- readline(prompt = paste0("Do you really want to delete project ", 
                                         name, "(", cProj, ")? (y/n): "))
    }
    
    if (answer == "y") {
      outBit <- command(list(delete = NULL, project = NULL, lib = .filepath(x), 
                             pid = cProj, force = NULL), .session(x))
    } else {
      outBit <- paste0("Deletion of project " , cProj, " skipped")
    }
    
    if (outBit == "saved"){ 
      message(paste0("Project " , cProj, " deleted"))
      outBit <- TRUE
    } else{
      message(outBit)
      outBit <- FALSE
    }
    
    out[[as.character(cProj)]] <- outBit
  }
  
  if (length(out) == 1) {
    out <- out[[1]]
  }
  
  return(out)
}


deleteScenarioDatasheet <- function(x, datasheet, scenario, 
                                    allScenarios, out = list(), force){
  ScenarioId <- NULL
  
  if (is.element(class(x), c("Scenario"))) {
    datasheets <- .datasheets(x, refresh = TRUE)
    scenarioSet <- scenario(.ssimLibrary(x), summary = TRUE)
  } else {
    datasheets <- .datasheets(.scenario(x, scenario = scenario[1]))
    scenarioSet <- scenario(x, summary = TRUE)
  }
  
  out <- list()
  for (i in seq(length.out = length(scenario))) {
    cScn <- scenario[i]
    name <- allScenarios$Name[allScenarios$ScenarioId == cScn]
    
    cProj <- subset(scenarioSet, ScenarioId == cScn)$ProjectId
    outBit <- deleteDatasheet(x, datasheet = datasheet, datasheets = datasheets, 
                              cProj = cProj, cScn = cScn, cProjName = "", 
                              cScnName = name, out = out, force = force)
    
    if (outBit == "saved"){ 
      message(paste0("Datasheet " , datasheet, " deleted"))
      outBit <- TRUE
    } else{
      message(outBit)
      outBit <- FALSE
    }
    out[[as.character(cScn)]] <- outBit
  }
  
  if (length(out) == 1) {
    out <- out[[1]]
  }
  
  return(out)
}

deleteScenario <- function(x, scenario, allScenarios, out = list(), force){
  
  ScenarioId <- NULL
  
  for (i in seq(length.out = length(scenario))) {
    cScn <- scenario[i]
    name <- allScenarios$Name[allScenarios$ScenarioId == cScn]
    
    cProj <- subset(allScenarios, ScenarioId == cScn)$ProjectId
    
    if (force) {
      answer <- "y"
    } else {
      answer <- readline(prompt = paste0("Do you really want to remove scenario ", 
                                         name, "(", cScn, ")? (y/n): "))
    }
    
    if (answer == "y") {
      outBit <- command(list(delete = NULL, scenario = NULL, lib = .filepath(x), 
                             sid = cScn, force = NULL), .session(x))
    } else {
      outBit <- paste0("Deletion of scenario " , cProj, " skipped")
    }
    
    if (outBit == "saved"){ 
      message(paste0("Scenario " ,cScn, " deleted"))
      outBit <- TRUE
    } else{
      message(outBit)
      outBit <- FALSE
    }
    
    out[[as.character(cScn)]] <- outBit
  }
  
  if (length(out) == 1) {
    out <- out[[1]]
  }
  
  return(out)
}

deleteFolder <- function(x, folderId, folderName, out = list(), force){
  
  for (i in seq(length.out = length(folderId))) {
    
    folderIdToDelete <- folderId[i]
    folderNameToDelete <- folderName[i]
    
    if (force) {
      answer <- "y"
    } else {
      answer <- readline(prompt = paste0("Do you really want to remove folder ", 
                                         folderNameToDelete, "(", 
                                         folderIdToDelete, ")? (y/n): "))
    }
    
    if (answer == "y") {
      outBit <- command(list(delete = NULL, folder = NULL, lib = .filepath(x), 
                             fid = folderIdToDelete, force = NULL), .session(x))
    } else {
      outBit <- paste0("Deletion of folder ", folderNameToDelete, " skipped")
    }
    
    if (outBit == paste0("Folder deleted: ", folderIdToDelete)){ 
      message(paste0("Folder ", folderNameToDelete, " deleted"))
      outBit <- TRUE
    } else{
      message(outBit)
      outBit <- FALSE
    }
    
    out[[as.character(folderNameToDelete)]] <- outBit
  }
  
  if (length(out) == 1) {
    out <- out[[1]]
  }
  
  return(out)
}

deleteChart <- function(x, chartId, chartName, out = list(), force){
  
  for (i in seq(length.out = length(chartId))) {
    
    chartIdToDelete <- chartId[i]
    chartNameToDelete <- chartName[i]
    
    if (force) {
      answer <- "y"
    } else {
      answer <- readline(prompt = paste0("Do you really want to remove chart ", 
                                         chartNameToDelete, "(", chartIdToDelete, 
                                         ")? (y/n): "))
    }
    
    if (answer == "y") {
      args <- list(delete = NULL, 
                   chart = NULL, lib = .filepath(x), 
                   cid = chartIdToDelete, force = NULL) 
      outBit <- command(args, session = .session(x), 
                        program = "SyncroSim.VizConsole.exe")
    } else {
      outBit <- paste0("Deletion of chart ", chartNameToDelete, " skipped")
    }
    
    if (outBit == paste0("Chart deleted: ", chartIdToDelete)){ 
      message(paste0("Chart ", chartNameToDelete, " deleted"))
      outBit <- TRUE
    } else{
      message(outBit)
      outBit <- FALSE
    }
    
    out[[as.character(chartNameToDelete)]] <- outBit
  }
  
  if (length(out) == 1) {
    out <- out[[1]]
  }
  
  return(out)
}

getIdsFromListOfObjects <- function(ssimObject, expecting = NULL, scenario = NULL, project = NULL) {
  if (is.null(expecting)) {
    expecting <- class(ssimObject[[1]])
  }
  if (class(ssimObject[[1]]) != expecting) {
    if (expecting == "character") {
      stop("Expecting a list of library paths.")
    } else {
      stop("Expecting a list of ", expecting, "s.")
    }
  }
  cLib <- .ssimLibrary(ssimObject[[1]])
  if (!is.null(scenario)) {
    warning("scenario argument is ignored when ssimObject is a list.")
  }
  if (!is.null(project)) {
    warning("project argument is ignored when ssimObject is a list.")
  }
  objs <- c()
  for (i in seq(length.out = length(ssimObject))) {
    cObj <- ssimObject[[i]]
    if (expecting == "character") {
      cObj <- .ssimLibrary(cObj)
    }

    if (class(cObj) != expecting) {
      stop("All elements of ssimObject should be of the same type.")
    }
    if ((expecting != "character") && (.filepath(cObj) != .filepath(cLib))) {
      stop("All elements of ssimObject must belong to the same library.")
    }
    if (expecting == "Scenario") {
      objs <- c(objs, .scenarioId(cObj))
    }
    if (expecting == "Project") {
      objs <- c(objs, .projectId(cObj))
    }
    if (is.element(expecting, c("character", "SsimLibrary"))) {
      objs <- c(objs, cObj)
    }
  }
  ssimObject <- cLib
  if (expecting == "character") {
    expecting <- "SsimLibrary"
  }
  return(list(ssimObject = ssimObject, objs = objs, expecting = expecting))
}

# get scnSet
getScnSet <- function(ssimObject) {
  # get current scenario info
  ScenarioId <- NULL
  tt <- command(list(list = NULL, scenarios = NULL, csv = NULL, lib = .filepath(ssimObject)), .session(ssimObject))
  scnSet <- .dataframeFromSSim(tt, localNames = FALSE, convertToLogical = c("IsReadOnly"))
  names(scnSet)[names(scnSet) == "Id"] <- "ScenarioId"
  names(scnSet)[names(scnSet) == "ProjectId"] <- "ProjectId"
  names(scnSet)[names(scnSet) == "ParentId"] <- "ParentId"
  if (nrow(scnSet) == 0) {
    scnSet <- merge(scnSet, data.frame(ScenarioId = NA, exists = NA), all = TRUE)
    scnSet <- subset(scnSet, !is.na(ScenarioId))
  } else {
    scnSet$exists <- TRUE
  }
  return(scnSet)
}

# get projectSet
getProjectSet <- function(ssimObject) {
  ProjectId <- NULL
  tt <- command(list(list = NULL, projects = NULL, csv = NULL, lib = .filepath(ssimObject)), .session(ssimObject))
  projectSet <- .dataframeFromSSim(tt, localNames = FALSE, convertToLogical = c("IsReadOnly"))
  if (nrow(projectSet) == 0) {
    projectSet[1, "ProjectId"] <- NA
  }
  names(projectSet)[names(projectSet) == "Id"] <- "ProjectId"
  projectSet$exists <- TRUE
  projectSet <- subset(projectSet, !is.na(ProjectId))
  return(projectSet)
}

# make first character of string lower case
camel <- function(x) {
  substr(x, 1, 1) <- tolower(substr(x, 1, 1))
  x
}

# make first character of string upper case
pascal <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

# https://stackoverflow.com/questions/26083625/how-do-you-include-data-frame-output-inside-warnings-and-errors
printAndCapture <- function(x) {
  paste(capture.output(print(x)), collapse = "\n")
}

# Get name of parent scenario from result scenario name.
.getParentName <- function(x) {
  out <- strsplit(x, " ([", fixed = TRUE)[[1]][1]
  return(out)
}

# Dataframe from SyncroSim output
#
# Converts output from SyncroSim to a dataframe.
#
# @param x Output from \code{\link{command()}}
# @param colNames A vector of column names.
# @param csv If T assume comma separation. Otherwise, assume undefined white space separation.
# @param localNames If T, remove spaces from column names and make camelCase.
# @return A data frame of output from the SyncroSim console.
# @examples
# # Use a default session to create a new library
# myArgs = list(list=NULL,columns=NULL,lib=".",sheet="stsim_Stratum",pid=1)
# myOutput = command(args=myArgs,mySsim)
# myDataframe = dataframeFromSSim(myOutput)
# myDataframe
#
# Note: this function is now internal. Should now only be called from datasheet.

.dataframeFromSSim <- function(x, colNames = NULL, csv = TRUE, localNames = TRUE, convertToLogical = NULL) {
  if (is.null(colNames)) {
    header <- TRUE
  } else {
    header <- FALSE
  }
  if (csv) {
    con <- textConnection(x)
    out <- read.csv(con, stringsAsFactors = FALSE, header = header)
    close(con)
  } else {
    if (1) {
      # Do the old wierd thing if not csv
      while (max(grepl("   ", x, fixed = TRUE))) {
        x <- gsub("   ", "  ", x, fixed = TRUE)
      }
      x <- gsub("  ", ",", x, fixed = TRUE)
      con <- textConnection(x)
      out <- read.csv(con, stringsAsFactors = FALSE, header = header, sep = ",", encoding = "UTF-8")
      if (!is.null(colNames)) {
        lastName <- names(out)[length(names(out))]
        if ((ncol(out) > length(colNames)) & (sum(!is.na(out[[lastName]])) == 0)) {
          out[[lastName]] <- NULL
        }
        names(out) <- colNames
      }
    }
    close(con)
  }
  if (localNames) {
    names(out) <- gsub(" ", "", names(out))
    names(out) <- gsub(".", "", names(out), fixed = TRUE)
    names(out) <- sapply(names(out), camel)
  }
  if (!is.null(convertToLogical)) {
    for (i in seq(length.out = length(convertToLogical))) {
      cName <- convertToLogical[[i]]
      if (is.element(cName, names(out))) {
        out[[cName]][out[[cName]] == "No"] <- FALSE
        out[[cName]][out[[cName]] == "Yes"] <- TRUE
        if (localNames) {
          out[[cName]] <- as.logical(out[[cName]])
        }
      }
    }
  }
  return(out)
}

# Gets chart info for a Project.
#
# @param x A Project object.
# @return A dataframe of chart info, including chart IDs, names
getChartData <- function(x) {
  
  ChartId = NULL
  X = NULL
  
  args <- list(lib = .filepath(x), chart = NULL, list = NULL, 
               charts = NULL, pid = .projectId(x))
  tt <- command(args = args, session = .session(x), 
                program = "SyncroSim.VizConsole.exe")
  out <- .dataframeFromSSim(tt, localNames = TRUE, csv=FALSE)
  
  # Clean up dataframe names and columns
  names(out) <- sapply(names(out), pascal)
  colnames(out)[colnames(out) == "Id"] ="ChartId"
  out <- subset(out, select = -c(X))
  
  if (is(x, "Chart")){
    out <- subset(out, ChartId == x@chartId)
  }
  
  return(out)
}

# Gets folder info from an SsimLibrary, Project, Scenario, or Folder.
#
# @param x An SsimLibrary, Project, Scenario, or Folder object. Or a path to a SyncroSim library on disk.
# @return A dataframe of folder info, including folder IDs, names, owner, date last modified, 
# read only status, and published status.
getFolderData <- function(x) {
  
  FolderId = NULL
  X = NULL
  
  args <- list(lib = .filepath(x), list = NULL, folders = NULL)
  tt <- command(args = args, session = .session(x))
  out <- .dataframeFromSSim(tt, localNames = TRUE, csv=FALSE)
  
  # Clean up dataframe names and columns
  names(out) <- sapply(names(out), pascal)
  colnames(out)[colnames(out) == "Id"] = "FolderId"
  out <- subset(out, select = -c(X))
  
  if (is(x, "Folder")){
    out <- subset(out, FolderId == x@folderId)
  }
  
  return(out)
}

# Gets the parent Folder ID given the SsimLibrary and the child Folder ID.
#
# @param x SyncroSim Library, Project, Scenario, or Folder object.
# @param folderId integer value of the child Folder ID.
# @param item string indicating type of the child item ("Folder" or "Scenario")
# @param item string indicating type of the child item ("Folder" or "Scenario")
# @return integer corresponding to the parent folder ID or project ID.
getParentFolderId <- function(x, id, item="Folder") {
  
  df <- getLibraryStructure(x)
  if ((item == "Scenario") && (x@parentId != 0)){
    item <- "Result(S)"
  }
  childRowInd <- which((df$id == id) & (df$item == item))
  childRowInd <- which((df$id == id) & (df$item == item))
  parentRowInd <- childRowInd - 1
  childRow <- df[childRowInd, ]
  childLevel <- as.numeric(childRow$level)
  parentLevel <- childLevel
  
  while (parentLevel >= childLevel){
    parentRow <- df[parentRowInd, ]
    parentLevel <- as.numeric(parentRow$level)
    parentRowInd <- parentRowInd - 1
  }
  
  if (parentRow$item == "Folder"){
    return(as.numeric(parentRow$id))
  } else {
    return(0)
  }
}

# Moves a scenario into the specified folder
#
# @param x SyncroSim Library, Project, Scenario, or Folder object.
# @param pid integer value of the Project ID.
# @param sid integer value of the Scenario ID
# @param folder folder object, character, or integer value of the Folder ID
addScenarioToFolder <- function(x, pid, sid, folder) {
  
  Name = NULL
  
  # Convert folder to fid and validate folder name
  if (is.numeric(folder)){
    fid <- folder
  } else if (is(folder, "Folder")){
    fid <- folder@folderId
  } else if (is.character(folder)) {
    folderData <- getFolderData(x)
    fid <- subset(folderData, Name == folder)$FolderId
    if (length(fid) == 0){
      stop(paste0("Folder name ", folder, " does not exist."))
    } else if (length(fid) > 1){
      stop(paste0("Folder name ", folder, " is not unique. Please provide the Folder ID."))
    }
  }
  
  if (fid != 0){
    args <- list(lib = .filepath(x), move = NULL, scenario = NULL, 
                 sid = sid, tfid = fid, tpid = pid)
    tt <- command(args = args, session = .session(x))
    if (!identical(tt, "saved")) {
      stop(tt)
    }
  }
  
  return(fid)
}


# Gets the library structure as a dataframe. Shows which Scenarios belong 
# to which projects, which folders belong to which projects or folders, etc.
#
# @param x SyncroSim Library, Project, Scenario, or Folder object.
# @return dataframe of levels, items, and IDs.
getLibraryStructure <- function(x) {
  
  args <- list(list = NULL, library = NULL, lib = .filepath(x), tree = NULL)
  tt <- command(args = args, session = .session(x))
  tt <- gsub("|", " ", tt, fixed=TRUE)
  matches <- regmatches(tt, regexpr("^\\s+", tt))
  levels <- sapply(matches, nchar) / 3
  
  libStructureDF <- data.frame(level = numeric(), item = character(), 
                               id = numeric(), stringsAsFactors = F)
  
  i <- 0
  for (entry in tt){
    
    if (i == 0){
      level <- 0
      item <- "Library"
      id <- 0
    } else {
      level <- as.numeric(levels[i])
      item <- regmatches(entry, 
                         regexec("+- \\s*(.*?)\\s* \\[", 
                                 entry))[[1]][2]
      if (is.na(item)){
        # Case when item is Dependency or Result Scenario
        item <- regmatches(entry, 
                           regexec("\\s*(.*?)\\s* \\[", 
                                   entry))[[1]][2]
      }
      
      id <- regmatches(entry, 
                       regexec(paste0("+- ", item, " \\[\\s*(.*?)\\s*\\]"), 
                               entry))[[1]][2]
      if (is.na(id)){
        # Case when item is Dependency or Result Scenario
        id <- regmatches(entry, 
                         regexec(paste0(" \\[\\s*(.*?)\\s*\\]:"), 
                                 entry))[[1]][2]
        level <- level - 2 # level is actually 2 above 
      }
      id <- suppressWarnings(as.numeric(id))
    }
    
    libStructureDF[i+1, ] <- c(level, item, id)
    
    i = i + 1
  }
  
  libStructureDF <- libStructureDF[!is.na(libStructureDF$item),]
  libStructureDF <- libStructureDF[!is.na(libStructureDF$item),]
  return(libStructureDF)
}

# Gets datasheet summary info from an SsimLibrary, Project or Scenario.
#
# @details
# See \code{\link{datasheet}} for discussion of optional/empty/sheetName/lookupsAsFactors arguments.
# \itemize{
#   \item {If x/project/scenario identify a scenario: }{Returns library, project, and scenario scope datasheets.}
#   \item {If x/project/scenario identify a project (but not a scenario): }{Returns library and project scope datasheets.}
#   \item {If x/project/scenario identify a library (but not a project or scenario): }{Returns library scope datasheets.}
# }
#
# @param x An SsimLibrary, Project or Scenario object. Or a path to a SyncroSim library on disk.
# @param project Project name or id. Ignored if x is a Project.
# @param scenario Scenario name or id. Ignored if x is a Scenario.
# @param scope "scenario","project", "library", "all", or NULL.
# @param refresh If FALSE (default) names are retrieved from x@datasheetNames. If TRUE names are retrieved using a console call (slower).
# @param core if FALSE (default) names are retrieved from x@datasheetNames. If TRUE names are retrieved using a console call and include core datasheets.
# @return A dataframe of datasheet names.
# @examples
#
# Note: this function is now internal. Should now only be called from datasheet.

datasheets <- function(x, project = NULL, scenario = NULL, scope = NULL, refresh = FALSE, core = FALSE) {
  if (!is(x, "SsimObject")) {
    stop("expecting SsimObject.")
  }
  
  x <- .getFromXProjScn(x, project, scenario)
  
  # Get datasheet dataframe
  if (!refresh & !core) {
    datasheets <- x@datasheetNames
  } else if (!core) {
    tt <- command(c("list", "datasheets", "csv", paste0("lib=", .filepath(x))), .session(x))
    datasheets <- .dataframeFromSSim(tt, convertToLogical = c("isOutput", "isSingle"))
    datasheets$scope <- sapply(datasheets$scope, camel)
    # TO DO - export this info from SyncroSim
  } else {
    tt <- command(c("list", "datasheets", "csv", "includesys", paste0("lib=", .filepath(x))), .session(x))
    datasheets <- .dataframeFromSSim(tt, convertToLogical = c("isOutput", "isSingle"))
    datasheets$scope <- sapply(datasheets$scope, camel)
  }
  
  if (nrow(datasheets) == 0){
    return(datasheets)
  }
  
  datasheets$order <- seq(1, nrow(datasheets))
  if (!is.null(scope) && (scope == "all")) {
    datasheets$order <- NULL
    return(datasheets)
  }
  if (is.element(class(x), c("Project", "SsimLibrary"))) {
    datasheets <- subset(datasheets, scope != "scenario")
  }
  if (is.element(class(x), c("SsimLibrary"))) {
    datasheets <- subset(datasheets, scope != "project")
  }
  if (!is.null(scope)) {
    if (!is.element(scope, c("scenario", "project", "library"))) {
      stop("Invalid scope ", scope, ". Valid scopes are 'scenario', 'project', 'library' and NULL.")
    }
    cScope <- scope
    datasheets <- subset(datasheets, scope == cScope)
  }
  datasheets <- datasheets[order(datasheets$order), ]
  datasheets$order <- NULL
  return(datasheets)
}

# Internal helper - return uniquely identified and valid SyncroSim object

.getFromXProjScn <- function(ssimObject, project = NULL, scenario = NULL,
                             folder = NULL, chart = NULL,
                             convertObject = FALSE, returnIds = NULL, 
                             goal = NULL, complainIfMissing = TRUE) {
  # If x is scenario, ignore project and scenario arguments
  Freq <- NULL
  ProjectId <- NULL
  ScenarioId <- NULL
  
  if (!is.element(class(ssimObject), c("character", "SsimLibrary", "Project", 
                                       "Scenario", "Folder", "Chart"))) {
    stop("ssimObject should be a filepath, or an SsimLibrary/Scenario object.")
  }
  
  if (is(ssimObject, "character")) {
    ssimObject <- .ssimLibrary(ssimObject)
  }
  
  # Check for conflicts between ssimObject and project/scenario.
  if (is.element(class(ssimObject), 
                 c("Project", "Scenario", "Folder", "Chart")) & (!is.null(project))) {
    warning("project argument is ignored when ssimObject is a Project/Scenario/Folder/Chart or list of these.")
    project <- NULL
  }
  
  if (is.element(class(ssimObject), 
                 c("Scenario", "Folder", "Chart")) && (!is.null(scenario))) {
    warning("scenario argument is ignored when ssimObject is a Scenario/Folder/Chart or list of these.")
    scenario <- NULL
  }
  
  if (is.null(goal)){
    if (!is.null(project) || (is(ssimObject, "Project")) && is.null(c(scenario, chart, folder))) {
      goal <- "project"
      if (is.null(returnIds)) {
        if (length(project) > 1) {
          returnIds <- TRUE
        } else {
          returnIds <- FALSE
        }
      }
    } else if (!is.null(scenario) || (is(ssimObject, "Scenario"))){
      goal <- "scenario"
      if (is.null(returnIds)) {
        if (length(scenario) > 1) {
          returnIds <- TRUE
        } else {
          returnIds <- FALSE
        }
      }
    } else if (!is.null(folder) || is(ssimObject, "Folder")) {
      goal <- "folder"
      if (is.null(returnIds)) {
        if (length(folder) > 1) {
          returnIds <- TRUE
        } else {
          returnIds <- FALSE
        }
      }
    } else if (!is.null(chart) || is(ssimObject, "Chart")) {
      goal <- "chart"
      if (is.null(returnIds)) {
        if (length(chart) > 1) {
          returnIds <- TRUE
        } else {
          returnIds <- FALSE
        }
      }
    } else {
      if (is.null(project) && is.null(scenario) && is.null(folder) && is.null(chart)) {
        if (!is.null(returnIds) && returnIds) {
          return(list(ssimObject = ssimObject, project = NULL, scenario = NULL, goal = "library"))
        } else {
          return(ssimObject)
        }
      }
      stop("Error in getFromXProjScn()")
    }
  }
  
  # If the goal is a project, return one or more, or complain
  if (!is.null(goal) && (goal == "project")) {
    # if ssimObject is a scenario, return the parent project
    if (is.element(class(ssimObject), c("Scenario", "Folder", "Chart"))) {
      if (convertObject | !returnIds) {
        ssimObject <- new("Project", ssimObject, id = .projectId(ssimObject))
      }
    }
    
    if (is.element(class(ssimObject), c("Project", "Scenario", "Folder", "Chart"))) {
      if (returnIds) {
        project <- .projectId(ssimObject)
        if (convertObject) {
          ssimObject <- .ssimLibrary(ssimObject)
        }
      } else {
        return(ssimObject)
      }
    }
    scenario <- NULL
    # if not returned, need to get project
    
    # get current project info
    
    projectSet <- getProjectSet(ssimObject)
    
    if (is.null(project)) {
      if (nrow(projectSet) == 0) {
        if (returnIds) {
          projectSet$exists <- NULL
          return(list(ssimObject = ssimObject, project = NULL, scenario = NULL, projectSet = projectSet, goal = goal))
        } else {
          stop("No projects found in library.")
        }
      }
      project <- projectSet$ProjectId
    }
    
    # Now assume project is defined
    # distinguish existing projects from those that need to be made
    areIds <- is.numeric(project)
    
    if (areIds) {
      mergeBit <- data.frame(ProjectId = as.numeric(as.character(project)))
    } else {
      mergeBit <- data.frame(Name = project, stringsAsFactors = FALSE)
    }
    mergeBit$order <- seq(1:length(project))
    fullProjectSet <- merge(projectSet, mergeBit, all = TRUE)
    missingProjects <- subset(fullProjectSet, is.na(fullProjectSet$exists) & (!is.na(fullProjectSet$order)))
    if (complainIfMissing & (nrow(missingProjects) > 0)) {
      if (areIds) {
        stop("Project ids (", paste(missingProjects$ProjectId, collapse = ","), ") not found in ssimObject. ")
      } else {
        stop("Projects (", paste(missingProjects$Name, collapse = ","), ") not found in ssimObject. ")
      }
    }
    
    missingNames <- subset(missingProjects, is.na(missingProjects$Name))
    if (areIds & (nrow(missingNames) > 0)) {
      stop("Project ids (", paste(missingNames$ProjectId, collapse = ","), ") not found in ssimObject. To make new projects, please provide names (as one or more character strings) to the project argument of the project() function. SyncroSim will automatically assign project ids.")
    }
    
    # Stop if an element of project corresponds to more than one existing row of the project list
    if (!areIds) {
      checkDups <- subset(fullProjectSet, !is.na(order))
      dupNames <- subset(as.data.frame(table(checkDups$Name)), Freq > 1)
      if (nrow(dupNames) > 0) {
        # report the first error only
        cName <- dupNames$Var1[1]
        cIds <- checkDups$ProjectId[checkDups$Name == cName]
        stop(paste0("The library contains more than one project called ", cName, ". Specify a project id: ", paste(cIds, collapse = ",")))
      }
    }
    
    smallProjectSet <- subset(fullProjectSet, !is.na(order))
    if (!returnIds) {
      if (nrow(smallProjectSet) > 1) {
        stop("Cannot uniquely identify a project from ssimObject/project arguments.")
      }
      if (!smallProjectSet$exists) {
        stop("Project ", project, " not found in the ssimObject.")
      }
      return(new("Project", ssimObject, id = smallProjectSet$ProjectId, projects = fullProjectSet))
    }
    if (sum(is.na(smallProjectSet$exists)) == 0) {
      project <- smallProjectSet$ProjectId
    }
    
    return(list(ssimObject = ssimObject, project = project, scenario = scenario, projectSet = fullProjectSet, goal = goal))
  }
  
  # if goal is scenario, and we have one, return immediately
  if (!is.null(goal) && (goal == "scenario")) {
    if (is.element(class(ssimObject), c("Scenario"))) {
      if (returnIds) {
        project <- .projectId(ssimObject)
        scenario <- .scenarioId(ssimObject)
      } else {
        return(ssimObject)
      }
    }
    
    if (is(ssimObject, "Project")) {
      project <- .projectId(ssimObject)
    }
    
    if (convertObject & returnIds & is.element(class(ssimObject), c("Scenario", "Project"))) {
      ssimObject <- .ssimLibrary(ssimObject)
    }
    
    scnSet <- getScnSet(ssimObject)
    if (!is.null(project)) {
      scnSet <- subset(scnSet, is.element(ProjectId, project))
    }
    if (!is.null(scenario) && is.numeric(scenario)) {
      scnSet <- subset(scnSet, is.element(ScenarioId, scenario))
    }
    if (is.null(scenario)) {
      if (nrow(scnSet) == 0) {
        if (returnIds) {
          scnSet$exists <- NULL
          return(list(ssimObject = ssimObject, project = NULL, scenario = NULL, scenarioSet = scnSet, goal = goal))
        } else {
          stop("No scenarios found in ssimObject.")
        }
      }
      scenario <- scnSet$ScenarioId
    }
    
    # Now assume scenario is defined
    # distinguish existing scenarios from those that need to be made
    areIds <- is.numeric(scenario)
    if (areIds) {
      mergeBit <- data.frame(ScenarioId = scenario)
    } else {
      mergeBit <- data.frame(Name = scenario, stringsAsFactors = FALSE)
    }
    if (!is.null(project)) {
      mergeBit$ProjectId <- project
    }
    mergeBit$order <- seq(1:length(scenario))
    fullScnSet <- merge(scnSet, mergeBit, all = TRUE)
    missingScns <- subset(fullScnSet, is.na(fullScnSet$exists) & (!is.na(fullScnSet$order)))
    if (complainIfMissing & (nrow(missingScns) > 0)) {
      if (areIds) {
        stop("Scenario ids (", paste(missingScns$ScenarioId, collapse = ","), ") not found in ssimObject. ")
      } else {
        stop("Scenarios (", paste(missingScns$Name, collapse = ","), ") not found in ssimObject. ")
      }
    }
    
    missingNames <- subset(missingScns, is.na(missingScns$Name))
    if (areIds & (nrow(missingNames) > 0)) {
      stop("Scenario ids (", paste(missingNames$ScenarioId, collapse = ","), ") not found in ssimObject. To make new scenarios, please provide names (as one or more character strings) to the scenario argument of the scenario() function. SyncroSim will automatically assign scenario ids.")
    }
    
    # For scenarios that need to be made, assign project or fail
    makeSum <- sum(!is.na(fullScnSet$order) & is.na(fullScnSet$exists))
    if (makeSum > 0) {
      if (is.null(project)) {
        allProjects <- project(ssimObject, summary = TRUE)
        if (nrow(allProjects) > 1) {
          stop("Can't create new scenarios because there is more than one project in the ssimObject. Please specify the Project ssimObject to which new scenarios should belong.")
        }
        if (nrow(allProjects) == 0) {
          obj <- project(ssimObject, project = "project1")
          project <- .projectId(obj)
        } else {
          project <- allProjects$ProjectId
        }
      }
      if (is.null(project) || is.na(project)) {
        stop("Something is wrong")
      }
      fullScnSet$ProjectId[!is.na(fullScnSet$order) & is.na(fullScnSet$exists)] <- project
    }
    
    # Stop if an element of scenarios corresponds to more than one existing row of the scenario list
    if (!areIds) {
      checkDups <- subset(fullScnSet, !is.na(order))
      dupNames <- subset(as.data.frame(table(checkDups$Name)), Freq > 1)
      if (nrow(dupNames) > 0) {
        # report the first error only
        cName <- dupNames$Var1[1]
        cIds <- checkDups$ScenarioId[checkDups$Name == cName]
        stop(paste0("The ssimObject contains more than one scenario called ", cName, ". Specify a scenario id: ", paste(cIds, collapse = ",")))
      }
    }
    
    smallScenarioSet <- subset(fullScnSet, !is.na(order))
    if (!returnIds) {
      if (nrow(smallScenarioSet) > 1) {
        stop("Cannot uniquely identify a scenario from ssimObject/scenario arguments.")
      }
      if (!smallScenarioSet$exists) {
        stop("Scenario ", scenario, " not found in the ssimObject.")
      }
      return(new("Scenario", ssimObject, id = scenario, scenarios = fullScnSet))
    }
    if (sum(is.na(smallScenarioSet$exists)) == 0) {
      scenario <- smallScenarioSet$ScenarioId
    }
    
    return(list(ssimObject = ssimObject, project = project, scenario = scenario, scenarioSet = fullScnSet, goal = goal))
  }
  
  # if goal is chart, and we have one, return immediately
  if (!is.null(goal) && (goal == "chart")) {
    if (is.element(class(ssimObject), c("Chart"))) {
      return(ssimObject)
    }
  }
  
  # if goal is folder, and we have one, return immediately
  if (!is.null(goal) && (goal == "folder")) {
    if (is.element(class(ssimObject), c("Folder"))) {
      return(ssimObject)
    }
  }
  
  stop(paste0("Could not identify a SsimLibrary, Project or Scenario from ssimObject, project, and scenario arguments."))
}