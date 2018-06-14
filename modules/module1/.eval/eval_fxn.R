library(yaml)
library(tidyverse)
library(glue)

set_basepath <- function(type = c("data", "R")) {
  if (stringr::str_length(Sys.which("rstudio-server"))) {
    file.path("home/shared", type)
  } else {
    here::here(type)
  }
}

data_dir <- set_basepath("data")

score_submission <- function(submission_filename) {
  load(file.path(data_dir, "pson_expr_tpm_df.RData"))
  load(file.path(data_dir, "pson_expr_gene_info.RData"))
  load(file.path(data_dir, "pson_motility_tidy_df.RData"))
  
  answers <- yaml.load_file(submission_filename)
  
  gene <- gene_df %>% 
    filter(symbol == answers$gene) %>% 
    pluck("gene_id")
  
  colon_motil_df <- pson_motil_tidy_df %>% 
    filter(diagnosis == "Colon Cancer", 
           summary_metric == "speed_um_hr", 
           experimentalCondition == "HyaluronicAcid Collagen")
  
  colon_logtpm_df <- pson_expr_tpm_df %>% 
    filter(gene_id == gene) %>% 
    select(gene_id, one_of(colon_motil_df$sample)) %>% 
    gather(sample, tpm, -gene_id) %>% 
    mutate(logtpm = log2(tpm + 1)) %>% 
    left_join(colon_motil_df) %>% 
    select(gene_id, logtpm, average_value) %>% 
    mutate(average_value = if_else(average_value == max(average_value), 
                                   "faster", "slower")) %>% 
    spread(average_value, logtpm) %>% 
    mutate(delta = faster - slower)
  
  delta_match <- all_equal(
    round(colon_logtpm_df$delta, digits = 3),
    round(answers$delta, digits = 3)
  ) %>%
    isTRUE()
  
  if (delta_match) {
    msg <- glue("You found that `delta` was {d}. Me too — cool!",
                    d = round(answers$delta, digits = 3))
  } else {
    msg <- glue("Hmm... you said `delta` was {d}, but I found that it was ",
                    "{d0}. Maybe you swapped the row numbers for 'slower' ",
                    "and 'faster'.", 
                    d = round(answers$delta, digits = 3), 
                    d0 = round(colon_logtpm_df$delta, digits = 3))
  }
  answers["comment"] <- msg
  answers
}
