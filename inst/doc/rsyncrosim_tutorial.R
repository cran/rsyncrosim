params <-
list(EVAL = FALSE)

## ---- echo = FALSE, message = FALSE-------------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>", eval = params$EVAL)
options(tibble.print_min = 4, tibble.print_max = 4)
library(rsyncrosim)
library(raster)

## ---- echo = FALSE, message = FALSE-------------------------------------------
#  mySession <- session() # start default session
#  addPackage("stsim", mySession)
#  temp_dir <- tempdir()
#  libraryName <- file.path(temp_dir,"demoLib.ssim")
#  myLibrary <- ssimLibrary(name = libraryName, session = mySession, overwrite = T)

## -----------------------------------------------------------------------------
#  library(rsyncrosim)
#  library(raster)

## -----------------------------------------------------------------------------
#  stratumTif <- system.file("extdata", "initial-stratum.tif",
#                            package = "rsyncrosim")
#  sclassTif <- system.file("extdata", "initial-sclass.tif",
#                           package = "rsyncrosim")
#  ageTif <- system.file("extdata", "initial-age.tif",
#                        package = "rsyncrosim")

## ---- eval = FALSE------------------------------------------------------------
#  mySession <- session("path/to/install_folder")  # Create a Session based SyncroSim install folder
#  mySession <- session()                              # Using default install folder (Windows only)
#  mySession                                           # Displays the Session object
#  

## ---- eval = FALSE------------------------------------------------------------
#  addPackage("stsim", mySession)   # Get stsim package from SyncroSim online server (only the first time)
#  myLibrary <- ssimLibrary(name = "demoLibrary.ssim", session = mySession, overwrite = TRUE)

## -----------------------------------------------------------------------------
#  # Loads the existing default Project
#  myProject = project(myLibrary, project = "Definitions") # Using name for Project
#  myProject = project(myLibrary, project = 1) # Using projectId for Project

## -----------------------------------------------------------------------------
#  # Creates a Scenario object (associated with the default Project)
#  myScenario = scenario(myProject, scenario = "My first scenario")
#  myScenario

## -----------------------------------------------------------------------------
#  datasheet(myLibrary, summary = TRUE)

## ---- eval = FALSE------------------------------------------------------------
#  datasheet(myProject, summary = TRUE)
#  datasheet(myScenario, summary = TRUE)

## -----------------------------------------------------------------------------
#  # Returns a dataframe of the Terminology Datasheet
#  sheetData <- datasheet(myProject, name="stsim_Terminology")
#  str(sheetData)

## -----------------------------------------------------------------------------
#  # Edit the dataframe values
#  sheetData$AmountUnits <- "Hectares"
#  sheetData$StateLabelX <- "Forest Type"
#  
#  # Saves the edits back to the Library file
#  saveDatasheet(myProject, sheetData, "stsim_Terminology")

## -----------------------------------------------------------------------------
#  # Retrieves an empty copy of the Datasheet
#  sheetData <- datasheet(myProject, "stsim_Stratum", empty = TRUE)
#  
#  # Helper function in rsyncrosim to add rows to dataframes
#  sheetData <- addRow(sheetData, "Entire Forest")
#  
#  # Save edits to file
#  saveDatasheet(myProject, sheetData, "stsim_Stratum", force = TRUE)

## -----------------------------------------------------------------------------
#  forestTypes <- c("Coniferous", "Deciduous", "Mixed")
#  saveDatasheet(myProject, data.frame(Name = forestTypes), "stsim_StateLabelX", force = TRUE)

## -----------------------------------------------------------------------------
#  saveDatasheet(myProject, data.frame(Name = c("All")), "stsim_StateLabelY", force = TRUE)

## -----------------------------------------------------------------------------
#  stateClasses <- data.frame(Name = forestTypes)
#  stateClasses$StateLabelXID <- stateClasses$Name
#  stateClasses$StateLabelYID <- "All"
#  stateClasses$ID <- c(1, 2, 3)
#  saveDatasheet(myProject, stateClasses, "stsim_StateClass", force = TRUE)

## -----------------------------------------------------------------------------
#  transitionTypes <- data.frame(Name = c("Fire", "Harvest", "Succession"), ID = c(1, 2, 3))
#  saveDatasheet(myProject, transitionTypes, "stsim_TransitionType", force = TRUE)

## -----------------------------------------------------------------------------
#  transitionGroups <- data.frame(Name = c("Fire", "Harvest", "Succession"))
#  saveDatasheet(myProject, transitionGroups, "TransitionGroup", force = T)

## -----------------------------------------------------------------------------
#  transitionTypesGroups <- data.frame(TransitionTypeID = transitionTypes$Name,
#                                      TransitionGroupID = transitionGroups$Name)
#  saveDatasheet(myProject, transitionTypesGroups, "TransitionTypeGroup", force = T)

## -----------------------------------------------------------------------------
#  ageFrequency <- 1
#  ageMax <- 101
#  ageGroups <- c(20, 40, 60, 80, 100)
#  
#  saveDatasheet(myProject, data.frame(Frequency = ageFrequency, MaximumAge = ageMax),
#                "AgeType", force = TRUE)
#  saveDatasheet(myProject, data.frame(MaximumAge = ageGroups), "stsim_AgeGroup", force = TRUE)

## -----------------------------------------------------------------------------
#  myScenario <- scenario(myProject, "No Harvest")

## ---- eval = FALSE------------------------------------------------------------
#  # Subset the list to show only Scenario Datasheets
#  subset(datasheet(myScenario, summary = TRUE), scope == "scenario")

## -----------------------------------------------------------------------------
#  # Run simulation for 7 realizations and 10 timesteps
#  sheetName <- "stsim_RunControl"
#  sheetData <- data.frame(MaximumIteration = 7,
#                          MinimumTimestep = 0,
#                          MaximumTimestep = 10,
#                          isSpatial = TRUE)
#  saveDatasheet(myScenario, sheetData, sheetName)

## -----------------------------------------------------------------------------
#  # Add all the deterministic transitions
#  sheetName <- "stsim_DeterministicTransition"
#  sheetData <- datasheet(myScenario, sheetName, optional = T, empty = T)
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Coniferous",
#                                            StateClassIDDest = "Coniferous",
#                                            AgeMin = 21,
#                                            Location = "C1"))
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Deciduous",
#                                            StateClassIDDest = "Deciduous",
#                                            Location = "A1"))
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Mixed",
#                                            StateClassIDDest = "Mixed",
#                                            AgeMin = 11,
#                                            Location = "B1"))
#  saveDatasheet(myScenario, sheetData, sheetName)

## -----------------------------------------------------------------------------
#  # Add all the probabilistic transition pathways
#  sheetName <- "stsim_Transition"
#  sheetData <- datasheet(myScenario, sheetName, optional = T, empty = T)
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Coniferous",
#                                            StateClassIDDest = "Deciduous",
#                                            TransitionTypeID = "Fire",
#                                            Probability = 0.01))
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Coniferous",
#                                            StateClassIDDest = "Deciduous",
#                                            TransitionTypeID = "Harvest",
#                                            Probability = 1,
#                                            AgeMin = 40))
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Deciduous",
#                                            StateClassIDDest = "Deciduous",
#                                            TransitionTypeID = "Fire",
#                                            Probability = 0.002))
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Deciduous",
#                                            StateClassIDDest = "Mixed",
#                                            TransitionTypeID = "Succession",
#                                            Probability = 0.1,
#                                            AgeMin = 10))
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Mixed",
#                                            StateClassIDDest = "Deciduous",
#                                            TransitionTypeID = "Fire",
#                                            Probability = 0.005))
#  sheetData <- addRow(sheetData, data.frame(StateClassIDSource = "Mixed",
#                                            StateClassIDDest = "Coniferous",
#                                            TransitionTypeID = "Succession",
#                                            Probability = 0.1,
#                                            AgeMin = 20))
#  saveDatasheet(myScenario, sheetData, sheetName)

## ---- fig.align="center", fig.dim = c(5,5)------------------------------------
#  rStratum <- raster(stratumTif)
#  rSclass <- raster(sclassTif)
#  rAge <- raster(ageTif)
#  
#  plot(rStratum)
#  plot(rSclass)
#  plot(rAge)

## -----------------------------------------------------------------------------
#  sheetName <- "stsim_InitialConditionsSpatial"
#  sheetData <- list(StratumFileName = stratumTif,
#                    StateClassFileName = sclassTif,
#                    AgeFileName = ageTif)
#  saveDatasheet(myScenario, sheetData, sheetName)

## ---- fig.align="center", fig.dim = c(5,5), eval=FALSE------------------------
#  rStratumTest <- datasheetRaster(myScenario, sheetName, "StratumFileName")
#  rSclassTest <- datasheetRaster(myScenario, sheetName, "StateClassFileName")
#  rAgeTest <- datasheetRaster(myScenario, sheetName, "AgeFileName")
#  plot(rStratumTest)
#  plot(rSclassTest)
#  plot(rAgeTest)

## -----------------------------------------------------------------------------
#  sheetName <- "stsim_InitialConditionsNonSpatial"
#  sheetData <- data.frame(TotalAmount = 100,
#                          NumCells = 100,
#                          CalcFromDist = F)
#  saveDatasheet(myScenario, sheetData, sheetName)
#  datasheet(myScenario, sheetName)
#  
#  sheetName <- "stsim_InitialConditionsNonSpatialDistribution"
#  sheetData <- data.frame(StratumID = "Entire Forest",
#                          StateClassID = "Coniferous",
#                          RelativeAmount = 1)
#  saveDatasheet(myScenario, sheetData, sheetName)
#  datasheet(myScenario, sheetName)

## -----------------------------------------------------------------------------
#  # Transition targets - set harvest to 0 for this scenario
#  saveDatasheet(myScenario,
#                data.frame(TransitionGroupID = "Harvest",
#                           Amount = 0),
#                "stsim_TransitionTarget")

## -----------------------------------------------------------------------------
#  # Output options
#  # datasheet(myScenario, "stsim_OutputOptions")
#  sheetData <- data.frame(
#    SummaryOutputSC = T, SummaryOutputSCTimesteps = 1,
#    SummaryOutputTR = T, SummaryOutputTRTimesteps = 1
#  )
#  saveDatasheet(myScenario, sheetData, "stsim_OutputOptions")
#  sheetData <- data.frame(
#    RasterOutputSC = T, RasterOutputSCTimesteps = 1,
#    RasterOutputTR = T, RasterOutputTRTimesteps = 1,
#    RasterOutputAge = T, RasterOutputAgeTimesteps = 1
#  )
#  saveDatasheet(myScenario, sheetData, "stsim_OutputOptionsSpatial")

## -----------------------------------------------------------------------------
#  myScenarioHarvest <- scenario(myProject,
#                                scenario = "Harvest",
#                                sourceScenario = myScenario)
#  saveDatasheet(myScenarioHarvest, data.frame(TransitionGroupID = "Harvest",
#                                              Amount = 20),
#                "stsim_TransitionTarget")

## -----------------------------------------------------------------------------
#  datasheet(myProject, scenario = c("Harvest", "No Harvest"),
#            name = "stsim_TransitionTarget")

## -----------------------------------------------------------------------------
#  resultSummary <- run(myProject, scenario = c("Harvest", "No Harvest"),
#                       jobs = 7, summary = TRUE)

## -----------------------------------------------------------------------------
#  resultIDNoHarvest <- subset(resultSummary,
#                              parentID == scenarioId(myScenario))$scenarioId
#  resultIDHarvest <- subset(resultSummary,
#                            parentID == scenarioId(myScenarioHarvest))$scenarioId

## -----------------------------------------------------------------------------
#  outputStratumState <- datasheet(myProject,
#                                  scenario = c(resultIDNoHarvest, resultIDHarvest),
#                                  name = "stsim_OutputStratumState")

## ---- fig.align = TRUE, fig.dim = c(5,5)--------------------------------------
#  myRastersTimestep5 <- datasheetRaster(myProject,
#                                        scenario = resultIDHarvest,
#                                        "stsim_OutputSpatialState",
#                                        timestep = 5)
#  # Plot raster for timestep 5 (first realization only)
#  myRastersTimestep5
#  plot(myRastersTimestep5[[1]])

