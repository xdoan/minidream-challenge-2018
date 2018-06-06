library(yaml)
library(jsonlite)

create_module0_submission <- function() {
  submission_filename <- paste(Sys.getenv("USER"), "activity-0.yml", sep = "_")
  
  bday <<- my_bday_guess
  age <<- my_age_guess

  answers <- list(
    bday = bday, 
    age = age 
  )
  write_yaml(answers, submission_filename)
  submission_filename
}

create_module1_submission <- function() {
  submission_filename <- paste(Sys.getenv("USER"), "activity-1.yml", sep = "_")
  
  gene <<- my_gene
  delta <<- my_delta
  description <<- my_description
  rationale <<- my_rationale
  
  answers <- list(
    gene = gene, 
    delta = delta, 
    description = description, 
    rationale = rationale
  )

  write_yaml(answers, submission_filename)
  submission_filename
}

submit_module_answers <- function(module) {
  if (is.numeric(module)) {
    module <- as.character(module)
  }
  submission_filename <- switch(
    module,
    "0" = create_module0_submission(),    
    "1" = create_module1_submission()
  )
  submission_folder <- switch(
    module,
    "0" = "syn12369913",
    "1" = "syn12440746"
  )
  activity_submission <- synStore(
    File(path = submission_filename, parentId = submission_folder)
  )
  submission <- synSubmit(evaluation = "9612371", entity = activity_submission)
  
  message("")
  message(paste0("Successfully submitted file: '", submission_filename, "'"))
  message(paste0("... stored as '", fromJSON(s$entityBundleJSON)$entity$id, "'"))
  message(paste0("Submission ID: '", submission$id))
  
  return(submission)
  # print(paste0("Stored as: '", submission[[1]]$id, "'"))
}