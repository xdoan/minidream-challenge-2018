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

create_module2_submission <- function() {
  submission_filename <- paste(Sys.getenv("USER"), "activity-2.yml", sep = "_")
  
  distance_metric <<- my_distance_metric
  cluster_method <<- my_cluster_method
  num_clusters <<- my_num_clusters
  p_value <<- my_p_value
  
  answers <- list(
    distance_metric = distance_metric, 
    cluster_method = cluster_method, 
    num_clusters = num_clusters, 
    p_value = p_value
  )
  
  write_yaml(answers, submission_filename)
  submission_filename
}

create_module3_submission <- function() {
  submission_filename <- paste(Sys.getenv("USER"), "activity-3.yml", sep = "_")
  
  pc1_receptor <<- my_pc1_receptor
  tripleneg_met_association <<- my_tripleneg_met_association
  hpa_gene <<- my_hpa_gene
  hpa_is_enchanced <<- my_hpa_is_enchanced
  hpa_is_prognostic <<- my_hpa_is_prognostic
  
  answers <- list(
    pc1_receptor = pc1_receptor, 
    tripleneg_met_association = tripleneg_met_association, 
    hpa_gene = hpa_gene, 
    hpa_is_enchanced = hpa_is_enchanced,
    hpa_is_prognostic = hpa_is_prognostic
  )
  
  write_yaml(answers, submission_filename)
  submission_filename
}

create_module4_submission <- function() {
  submission_filename <- paste(Sys.getenv("USER"), "activity-4.yml", sep = "_")
  
  gene_count <<- my_gene_count
  go_subontology <<- my_go_subontology
  top_go_id <<- my_top_go_id
  go_description <<- my_go_description
  fav_go_term <<- my_fav_go_term
  rationale <<- my_rationale
  
  answers <- list(
    gene_count = gene_count, 
    go_subontology = go_subontology,
    top_go_id = top_go_id, 
    go_description = go_description, 
    fav_go_term = fav_go_term,
    rationale = rationale
  )
  
  write_yaml(answers, submission_filename)
  submission_filename
}

create_module5_submission <- function() {
  submission_filename <- paste(Sys.getenv("USER"), "activity-5.yml", sep = "_")
  
  model_gene <<- my_model_gene
  gene_relationship <<- my_gene_relationship
  gene_significance <<- my_gene_significance
  model_judgement <<- my_model_judgement
  prediction <<- my_prediction
  
  answers <- list(
    model_gene = model_gene, 
    gene_relationship = gene_relationship,
    gene_significance = gene_significance,
    model_judgement = model_judgement,
    prediction = prediction
  )
  
  write_yaml(answers, submission_filename)
  submission_filename
}

create_module7_submission <- function() {
  submission_filename <- paste(Sys.getenv("USER"), "activity-7.yml", sep = "_")
  
  celladhesion_count <<- my_celladhesion_count
  myosin_count <<- my_myosin_count
  high_cellline <<- my_high_cellline
  cms_match <<- my_cms_match
  explanation <<- my_explanation
  pathway_count <<- my_pathway_count
  takeaway <<- my_takeaway
  
  answers <- list(
    celladhesion_count = celladhesion_count, 
    myosin_count = myosin_count,
    high_cellline = high_cellline,
    cms_match = cms_match,
    explanation = explanation,
    pathway_count  = pathway_count,
    takeaway = takeaway
  )
  
  write_yaml(answers, submission_filename)
  submission_filename
}

submit_module_answers <- function(module, local = FALSE) {
  if (is.numeric(module)) {
    module <- as.character(module)
  }
  submission_filename <- switch(
    module,
    "0" = create_module0_submission(),    
    "1" = create_module1_submission(),
    "2" = create_module2_submission(),
    "3" = create_module3_submission(),
    "4" = create_module4_submission(),
    "5" = create_module5_submission(),
    "7" = create_module7_submission()
  )
  submission_folder <- switch(
    module,
    "0" = "syn18818751",
    "1" = "syn18818752",
    "2" = "syn18818753",
    "3" = "syn18818755",
    "4" = "syn18818756",
    "5" = "syn18818757",
    "7" = "syn18818759"
  )
  
  if (!local) {
    
    activity_submission <- synStore(
      File(path = submission_filename, parentId = submission_folder)
    )
    submission <- synSubmit(evaluation = "9614247", 
                            entity = activity_submission)
    
    message("")
    message(paste0("Successfully submitted file: '", submission_filename, "'"))
    message(paste0("... stored as '", 
                   fromJSON(submission$entityBundleJSON)$entity$id, "'"))
    message(paste0("Submission ID: '", submission$id))
    
    return(submission)
  } else {
    print(paste0("modules/module", module, "/.eval/eval_fxn.R"))
    source(paste0("modules/module", module, "/.eval/eval_fxn.R"))
    return(as.data.frame(score_submission(submission_filename)))
  }
  

}

create_dummy_files <- function(module, submission_folder) {
  minidream_roster_df %>% 
    filter(!is.na(SynapseUserName)) %>% 
    pluck("SynapseUserName") %>% 
    walk(
      function(x) { 
        text <- str_glue("this is a placeholder file for {s}", s = x)
        filename <- str_glue("module{m}_submissions/{s}_activity-{m}.yml", 
                             m = module, s = x) 
        write_yaml(text, filename)
        syn_id = synStore(File(path = filename, parentId = submission_folder))
        print(syn_id) 
      }
    )
}
