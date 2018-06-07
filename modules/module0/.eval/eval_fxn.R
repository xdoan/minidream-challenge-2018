library(yaml)
library(tidyverse)
library(lubridate)
library(glue)


score_submission <- function(submission_filename) {
  answers <- yaml.load_file(submission_filename)
  
  bday_guess <- parse_date_time(answers$bday, "md")
  bday_actual <- parse_date_time("06/09", "md")
  bday_diff <- bday_guess - bday_actual
  if (as.numeric(bday_diff) < 0) {
    bday_msg <- glue("Your guess was {d} days too early.",
                    d = abs(as.numeric(bday_diff)))
  } else {
    bday_msg <- glue("Your guess was {d} days too late.",
                    d = abs(as.numeric(bday_diff)))
  }
  
  age_actual <- 32
  age_diff <- answers$age - age_actual
  if (age_diff > 0) {
    age_msg <- glue("You overshot by {d} years.", d = age_diff)
  } else if (age_diff < 0) {
    age_msg <- glue("Under by {d} years.", d = abs(age_diff))
  } else {
    age_msg <- "Nailed it!"
  }
  
  if (age_diff > 15) {
    age_msg <- str_c(age_msg, " Oof — that's harsh.")
  } else if (age_diff < -10) {
    age_msg <- str_c(age_msg, " I guess I'm flattered?")
  }
  
  answers["bday_comment"] <- bday_msg
  answers["age_comment"] <- age_msg
  answers
}
