library(yaml)
library(tidyverse)
library(glue)
library(rprojroot)


score_submission <- function(submission_filename) {
  
  answers <- yaml.load_file(submission_filename) %>% 
    map(str_trim)
  gene_count <- as.integer(answers$gene_count)
  gc_actual <- 497L
  count_match <- gene_count == gc_actual
  msg_1 <- glue("I ended up with {gc} genes in my gene list.", 
                gc = gc_actual)
  
  go_results <- list(
    BP = list(
      name = "biological process",
      top_go_id = "GO:0022612",
      go_description = "gland morphogenesis"
    ),
    MF = list(
      name = "molecular function",
      top_go_id = "GO:0005520",
      go_description = "insulin-like growth factor binding"
    ),
    CC = list(
      name = "cellular component",
      top_go_id = "GO:0005912",
      go_description = "adherens junction"
    )
  )
  
  go_subontology <- answers$go_subontology
  if (is.null(go_subontology)) {
    go_subontology <- go_results %>% 
      keep(~ .$top_go_id == answers$top_go_id) %>% 
      names()
    answers$go_subontology <- go_subontology
  }
  
  go_values <- go_results[[go_subontology]]
  msg_2 <- glue("For {name} ({subont}), I found that '{term}' ({id}) was the ",
                "most over-represented GO term",
                name = go_values$name,
                subont = go_subontology,
                term = go_values$go_description,
                id = go_values$top_go_id)
    

  answers["comment"] <- paste(msg_1, msg_2)
  answers
}

