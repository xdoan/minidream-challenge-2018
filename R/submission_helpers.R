library(yaml)

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
  # activity_submission <- synStore(
  #   File(path = submission_filename, parentId = "syn10142597")
  # )
  # submission <- submit(evaluation = "9604686", entity = activity1_submission)
  print(paste0("Successfully submitted file: '", submission_filename, "'"))
  # print(submission[[1]]$id)
}