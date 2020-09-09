library(yaml)
library(tidyverse)
library(glue)
library(rprojroot)


score_submission <- function(submission_filename) {
  
  answers <- yaml.load_file(submission_filename) %>% 
    map(str_trim)
  N_image <- as.integer(answers$N_image)
  N_half_var <- as.integer(answers$N_half_var)
  pc1_receptor <- answers$pc1_receptor
  #top_five_genes <- answers$top_five_genes
  subtype <- answers$subtype

  if (N_image > 50) {
  	msg_1 <- glue("That's quite a few dimensions to keep to capture the physical detail of the image.")
  }
  else if(N_image < 10){
  	msg_1 <- glue("You can't really differentiate the cell to well with that few dimensions capturing the image detail.")
  } 	
  else{
  	msg_1 <- glue("The number of components sounds about right to capture the full image physical detail!")
  } 	

  if (N_half_var == 21) {
  	msg_2 <- glue("To capture half the variation of the gene expression data that is the correct number of principal components!")
  }
  else{
  	msg_2 <- glue("Please revise the number of principal components needed to capture half the variation of the gene expression data.")
  } 	

  if (pc1_receptor == 'PR') {
  	msg_3 <- glue("You got the correct the correct principal component!")
  }
  else{
  	msg_3 <- glue("This is not the more informative principal component.")
  } 	
  

  #if (identical(top_five_genes, c("ADH1B", "ADIPOQ", "C7", "ABCA8", "TUSC5"))){
  # 	msg_4 <- glue("These are the 5 most important genes for PC2!")
  #}
  #else{
  # 	msg_4 <- glue("These are not the top 5 most informative genes for PC2.")
  #} 	


  if (subtype == 'luminal A'){
  	msg_4 <- glue("That is the correct subtype!")
  }
  else{
  	msg_4<- glue("This is not the correct subtype (please check your spelling and make sure you use only spaces and alphabetical symbols).")
  } 	


  #answers["comment"] <- paste(msg_1, msg_2, msg_3, msg_4, msg_5)
  answers["comment"] <- paste(msg_1, msg_2, msg_3, msg_4)
  answers
}

