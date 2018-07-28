library(yaml)
library(tidyverse)
library(glue)
library(rprojroot)


root_dir <- find_root(is_rstudio_project, thisfile())
data_dir <- file.path(root_dir, "data")

score_submission <- function(submission_filename) {
  goldstandard_file <- file.path(data_dir, "clutchforce_mean-data.yml")
  goldstandard <- yaml.load_file(goldstandard_file)
  goldstandard_df <- as.tibble(goldstandard)
  answers <- yaml.load_file(submission_filename)

  cs_s <- summary(lm(goldstandard$csMean ~ answers$clutchState))
  cs_sse <- sum((goldstandard$csMean - answers$clutchState)^2)
  answers$cs_sse <- sprintf("%0.4f", cs_sse)
  answers$cs_rmse <- sprintf("%0.3f", sqrt(mean(cs_s$residuals^2)))
  
  cs_check_df <- goldstandard_df %>% 
    mutate(
      cs_upper = csMean + csSD, 
      cs_lower = csMean - csSD,
      cs_test = answers$clutchState, 
      cs_in_sd = cs_test >= cs_lower & cs_test <= cs_upper,
      cs_in_range = cs_test >= csMin & cs_test <= csMax
    )
  
  sp_s <- summary(lm(goldstandard$subPosMean ~ answers$substratePosition))
  sp_sse <- sum((goldstandard$subPosMean - answers$substratePosition)^2)
  answers$sp_sse <- sprintf("%0.4f", sp_sse)
  answers$sp_rmse <- sprintf("%0.3f", sqrt(mean(sp_s$residuals^2)))
  
  sp_check_df <- goldstandard_df %>% 
    mutate(
      sp_upper = subPosMean + subPosSD, 
      sp_lower = subPosMean - subPosSD, 
      sp_test = answers$substratePosition, 
      sp_in_sd = sp_test >= sp_lower & sp_test <= sp_upper,
      sp_in_range = sp_test >= subPosMin & sp_test <= subPosMax
    )
  
  msg_1 <- str_glue(
    "{cs_sd} of your simulated data points for number of bound ",
    "clutches and {sp_sd} of substrate position points were ",
    "within one standard deviation of the mean values from our ",
    "100 simulations. We expect lots of variation from run to run, ",
    "so that's not necessarily good or bad.",
    cs_sd = sprintf("%0.2f%%", mean(cs_check_df$cs_in_sd) * 100),
    sp_sd = sprintf("%0.2f%%", mean(sp_check_df$sp_in_sd) * 100)
  )
  
  msg_2 <- str_glue(
    "{cs_ir} of your data points number of bound clutches and {sp_ir} ",
    "of substrate position points were within the full range of values ",
    "observed across our 100 simulations. Does that look better?",
    cs_ir = sprintf("%0.2f%%", mean(cs_check_df$cs_in_range) * 100),
    sp_ir = sprintf("%0.2f%%", mean(sp_check_df$sp_in_range) * 100)
  )
  
  answers["comment"] <-paste(msg_1, msg_2)
  
  answers$clutchState <- NULL
  answers$substratePosition <- NULL

  answers
}

score_submission('jaeddy_activity-6.yml')
