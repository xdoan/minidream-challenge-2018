library(synapser)
library(tidyverse)
library(jsonlite)

# setup -------------------------------------------------------------------

synLogin()
eval_id <- "9614247"

# fetch submissions -------------------------------------------------------

build_submission_table <- function(eval_id) {
  submissions <- as.list(synGetSubmissions(eval_id))
  map_df(submissions, function(x) {
    x$json() %>% 
      fromJSON() %>% 
      keep(is_character)
  })
}

submission_df <- build_submission_table(eval_id)

# annotate submissions ----------------------------------------------------

get_submission_annotations <- function(submission_id) {
  synGetSubmissionStatus(submission_id) %>% 
    .$json() %>% 
    fromJSON() %>% 
    pluck("annotations") %>% 
    keep(is_list) %>% 
    imap(~ spread(., key, value) %>% 
           select(-isPrivate) %>% 
           rename_all(funs(str_c(.y, ., sep = "_")))) %>% 
    bind_cols()
}

submission_df <- submission_df %>% 
  mutate(annots = map(id, get_submission_annotations)) %>% 
  unnest(annots)
