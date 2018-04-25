usePackage <- function(p) 
{
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
usePackage("pacman")

p_load("tidyverse")
p_load("dplyr")
p_load("plyr")
p_load("reshape")
p_load("synapser")
p_load("ggplot2")
p_load("gridExtra")

#  --------------------------------------------------------
options(stringsAsFactors = FALSE)
#  --------------------------------------------------------
synLogin()

# ---------------------------------------------------------
# summary of motility of cell lines captured via imaging 
brca.view <- synTableQuery("SELECT * FROM syn7747734 WHERE diagnosis = 'Breast Cancer' AND study = 'Motility'") %>% as.data.frame()
brca.view <- brca.view[ ,-c(1:3)]

motility.summary <- brca.view[grepl("summary", brca.view$name),]
dim(motility.summary)
# ---------------------------------------------------------
# expression quantification and sample mappings 
sample.map <- synTableQuery("SELECT replace(name, '_rsem.genes.results.txt', '') as sample, catalogNumber, cellType, experimentalCondition, organ, tumorType FROM syn10320914 WHERE diagnosis = 'Breast Cancer'  AND study = 'RNA Study' And fileFormat = 'txt' And name like '%rsem%'") %>% as.data.frame()
sample.map <- sample.map[ ,-c(1:3)]

expr.view <- synTableQuery("SELECT * FROM syn10320914 WHERE diagnosis = 'Breast Cancer'  AND study = 'RNA Study' And fileFormat = 'txt' And name like '%rsem%'") %>% as.data.frame()
expr.view <- expr.view[ ,-c(1:3)]

# ---------------------------------------------------------
summar.motility.list <- lapply(seq_along(motility.summary$id), function(i){
  
  summary.f <- read.delim(file = synGet(motility.summary[i,"id"])$path, sep = "\t")
  # remove additional information about the maximum hour ranned 
  summary.f <- summary.f[1:4, ]
  
  # clean and standardize columns and row names based on readme info 
  # ftp://caftpd.nci.nih.gov/psondcc/PhysicalCharacterization/Motility/README.txt
  colnames(summary.f) <-  c("end_to_end_distance_um",	"total_distance_um",	"speed_um_over_hr")
  rownames(summary.f) <- c("average_value", "total_number_of_cells_tracked" , "standard_deviation", "standard_error")
  summary.f <- as.data.frame(t(summary.f))
  
  # append annotations for downstream analysis 
  summary.f <- rownames_to_column(summary.f, "summary_metrics")
  summary.f$cellLine <- motility.summary[i, "cellLine"]
  summary.f$experimentalCondition <- motility.summary[i, "experimentalCondition"]
  summary.f$catalogNumber <- motility.summary[i, "catalogNumber"]
  
  summary.f <- transform(summary.f, average_value = as.numeric(average_value), 
            total_number_of_cells_tracked = as.numeric(total_number_of_cells_tracked), 
            standard_deviation = as.numeric(standard_deviation), 
            standard_error = as.numeric(standard_error))
  
  return(summary.f)
})
summary.motility.df <- as.tibble(do.call(rbind, summar.motility.list))
# save(summary.motility.df, file = "summary_motility_df.RData")

summary.motility.df %>%
  ggplot(aes(x = cellLine, y = average_value)) +
  geom_col(aes(fill = experimentalCondition), position = "dodge") +
  facet_wrap(~ summary_metrics) 
  # geom_errorbar(aes(aes(ymin = average_value - standard_error, ymax = average_value + standard_error)), size = 0.5,   
  #               width = 0.25, position = position_dodge(0.9))