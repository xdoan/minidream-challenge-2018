library(yaml)
library(tidyverse)
library(lubridate)
library(glue)


score_submission <- function(submission_filename) {
  answers <- yaml.load_file(submission_filename)
  
  nc_bound_final_guess <- answers$nc_bound_final
  nc_bound_final_actual <- 68.2

  nc_bound_final_diff <- nc_bound_final_guess - nc_bound_final_actual 
  
  if(as.numeric(nc_bound_final_diff) == 0)  
  {
	nc_bound_final_msg <- "Your solution is correct!"
  }
  else if (as.numeric(nc_bound_final_diff) < 0) {
    nc_bound_final_msg <- glue("Your solution was {d} lower",
                    d = abs(as.numeric(nc_bound_final_diff)))
  } else {
    nc_bound_final_msg <- glue("Your solution was {d} higher .",
                    d = abs(as.numeric(nc_bound_final_diff)))
  }


  time_half_guess <- answers$time_half
  time_half_actual <- 0.63

  time_half_diff <- time_half_guess - time_half_actual  
  if(as.numeric(time_half_diff) == 0)  
  {
	time_half_msg <- "Your solution is correct!"
  }
  else if (as.numeric(time_half_diff) < 0) {
    time_half_msg <- glue("Your solution was {d} lower",
                    d = abs(as.numeric(time_half_diff)))
  } else {
    time_half_msg <- glue("Your solution was {d} higher .",
                    d = abs(as.numeric(time_half_diff)))
  }


  unbound_freq_guess <- answers$unbound_freq
  unbound_freq_actual <- 6.7

  unbound_freq_diff <- unbound_freq_guess - unbound_freq_actual  
  if (as.numeric(unbound_freq_diff) < -1.7 ) {
    unbound_freq_msg <- glue("Your solution was {d} lower than expected",
                    d = abs(as.numeric(unbound_freq_diff)))
  } else if (as.numeric(unbound_freq_diff) > 3.3 ){
    unbound_freq_msg <- glue("Your solution was {d} higher than expected.",
                    d = abs(as.numeric(unbound_freq_diff)))
  }
  else {
   unbound_freq_msg <- "You are in the correct expected range!"
  }


  mforce_mean_guess <- answers$mforce_mean
  mforce_mean_actual <- 21e-12

  mforce_mean_diff <- mforce_mean_guess - mforce_mean_actual  
  if (as.numeric(mforce_mean_diff) < -1e-12 ) {
    mforce_mean_msg <- glue("Your solution was {d} lower than expected",
                    d = abs(as.numeric(mforce_mean_diff)))
  } else if (as.numeric(mforce_mean_diff) > 1e-12 ){
    mforce_mean_msg <- glue("Your solution was {d} higher than expected.",
                    d = abs(as.numeric(mforce_mean_diff)))
  }
  else {
   mforce_mean_msg <- "You are in the correct expected range!"
  }


  unbound_freq_deform_guess <- answers$unbound_freq_deform
  unbound_freq_deform_actual <- 0.085

  unbound_freq_deform_diff <- unbound_freq_deform_guess - unbound_freq_deform_actual  
  if (as.numeric(unbound_freq_deform_diff) < -0.015 ) {
    unbound_freq_deform_msg <- glue("Your solution was {d} lower than expected",
                    d = abs(as.numeric(unbound_freq_deform_diff)))
  } else if (as.numeric(unbound_freq_deform_diff) > 0.015 ){
    unbound_freq_deform_msg <- glue("Your solution was {d} higher than expected.",
                    d = abs(as.numeric(unbound_freq_deform_diff)))
  }
  else {
   unbound_freq_deform_msg <- "You are in the correct expected range!"
  }


  mforce_mean_deform_guess <- answers$mforce_mean_deform
  mforce_mean_deform_actual <- 80.8e-12

  mforce_mean_deform_diff <- mforce_mean_deform_guess - mforce_mean_deform_actual  
  if (as.numeric(mforce_mean_deform_diff) < -5.8e-12 ) {
    mforce_mean_deform_msg <- glue("Your solution was {d} lower than expected",
                    d = abs(as.numeric(mforce_mean_deform_diff)))
  } else if (as.numeric(mforce_mean_deform_diff) > 4.2e-12 ){
    mforce_mean_deform_msg <- glue("Your solution was {d} higher than expected.",
                    d = abs(as.numeric(mforce_mean_deform_diff)))
  }
  else {
   mforce_mean_deform_msg <- "You are in the correct expected range!"
  }


  #Equation_SubDeform_MForce_guess <- answers$Equation_SubDeform_MForce
  #Equation_SubDeform_MForce_actual <- "yes"

  #if (Equation_SubDeform_MForce != Equation_SubDeform_MForce_actual) {
  #  Equation_SubDeform_MForce_msg <- "Your answer is not correct. Note: please answer 'yes' or 'no'"
  #}   
  #else {
  # Equation_SubDeform_MForce_msg <- "Your answer is correct"
  #}

  
  answers["nc_bound_final_comment"] <- nc_bound_final_msg
  answers["time_half_comment"] <- time_half_msg
  answers["unbound_freq_comment"] <- unbound_freq_msg
  answers["mforce_mean_comment"] <- mforce_mean_msg
  answers["unbound_freq_deform_comment"] <-unbound_freq_deform_msg
  answers["mforce_mean_deform_comment"] <- mforce_mean_deform_msg
  #answers["Equation_SubDeform_MForce_comment"] <-Equation_SubDeform_MForce_msg
 
  answers
}
