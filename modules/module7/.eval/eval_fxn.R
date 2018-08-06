library(yaml)
library(tidyverse)
library(glue)
library(rprojroot)



score_submission <- function(submission_filename) {
  answers <- yaml.load_file(submission_filename)

  high_cellline <- answers$high_cellline
  cms_match <- answers$cms_match

  if (high_cellline == "T-47D" & cms_match == "no") {
    msg <- str_glue(
      "Your interpretation matches what I found — T-47D appears to have a ", 
      "greater abundance of clutches and motors, based on the expression of ",
      "37 cell adhesion and 68 myosin genes, respectively. Based on this ",
      "assumption, I would expect this cell line to exhibit greater motility ",
      "in the higher stiffness condition — but that's not the case."
    )
  } else if (high_cellline == "MDA-MB-231" & cms_match == "yes") {
    msg <- str_glue(
      "I can see how, if you interpreted MDA-MB-231 as the 'high motors and ",
      "clutches' cell line, then the fact that this cell line to exhibits ",
      "greater motility in the higher stiffness condition would indeed match ",
      "the CMS predictions. However, it's tough to justify that assumption ",
      "based on the expression of 37 cell adhesion and 68 myosin genes, ",
      "respectively, that we examined here."
    )
  } else {
    msg <- str_glue(
      "I'm not sure how you reached that particular conclusion. Check out ",
      "some of the other submissions for a couple interpretations that we'd ",
      "expect to see, given the data used."
    )
  }
  
  answers["comment"] <- msg

  answers
}

