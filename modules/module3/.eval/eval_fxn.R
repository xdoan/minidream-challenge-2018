library(yaml)
library(tidyverse)
library(glue)
library(rprojroot)


score_submission <- function(submission_filename) {

  answers <- yaml.load_file(submission_filename)
  pc1_receptor <- answers$pc1_receptor
  tripleneg_met_association <- answers$tripleneg_met_association
  hpa_gene <- answers$hpa_gene
  hpa_is_enchanced <- answers$hpa_is_enchanced
  hpa_is_prognostic <- answers$hpa_is_prognostic

  hpa_results <- list(
    AGR3 = list(
      is_enhanced = "yes",
      is_prognostic = "no"
    ),
    TFF1 = list(
      is_enhanced = "yes",
      is_prognostic = "yes" 
    ),
    ESR1 = list(
      is_enhanced = "yes",
      is_prognostic = "no" 
    ),
    TFF3 = list(
      is_enhanced = "no",
      is_prognostic = "no"
    ),
    C1orf64 = list(
      is_enhanced = "yes",
      is_prognostic = "no" 
    ),
    AGR2 = list(
      is_enhanced = "no",
      is_prognostic ="no" 
    )
  )
  
  receptor_match <- pc1_receptor == "PR"
  
  if (receptor_match) {
    msg_1 <- paste("Yep. For some reason, PR definitely seems to be more",
                 "associated with PC1 than HER2.")
  } else {
    msg_1 <- paste("When I looked, HER2 status actually seemed to be pretty",
                 "mixed across PC1 value... or maybe there's a typo in",
                 "your answer? (I was looking for 'PR'\n")
  }
  
  tripleneg_match <- tripleneg_met_association == "more"
  msg_2 <- paste("I found that triple-negative samples were more prevalent",
                 "when PC1 values were high. If PC1 were positively",
                 "correlated with metastasis, then triple-negative status",
                 "should be as well (more or less...).\n")
  
  hpa_values <- hpa_results[[answers$hpa_gene]]
  if (hpa_values$is_enhanced == "yes") {
    msg_3 <- paste("For that gene, I found that expression was 'enhanced'",
                  "in breast cancer.")
    
  } else {
    msg_3 <- paste("For that gene, I didn't see conclusive evidence",
                 "that expression is 'enhanced' in breast cancer.")
  }
  if (hpa_values$is_prognostic == "yes") {
    msg_3 <- paste(msg_3, "When I looked at HPA, I did find that gene to be",
                   "prognostic for breast cancer.")
  } else {
    msg_3 <- paste(msg_3, "When I looked at HPA, breast cancer was NOT listed",
                   "among genes for which tat gene was prognostic.")
  }

  
  answers["comment"] <- paste(msg_1, msg_2, msg_3)
  answers
}
