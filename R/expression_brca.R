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
# expression quantification and sample mappings 
sample.map <- synTableQuery("SELECT replace(name, '_rsem.genes.results.txt', '') as sample, catalogNumber, cellType, experimentalCondition, organ, tumorType FROM syn10320914 WHERE diagnosis = 'Breast Cancer'  AND study = 'RNA Study' And fileFormat = 'txt' And name like '%rsem%'") %>% as.data.frame()
sample.map <- sample.map[ ,-c(1:3)]

expr.view <- synTableQuery("SELECT * FROM syn10320914 WHERE diagnosis = 'Breast Cancer'  AND study = 'RNA Study' And fileFormat = 'txt' And name like '%rsem%'") %>% as.data.frame()
expr.view <- expr.view[ ,-c(1:3)]

expr.view$sample <- as.vector(sapply(expr.view$name, function(x){
  substring(x, 1 , 8)
}))

tpm.dat <- lapply(seq_along(expr.view$id), function(i){
  f <- read.delim(synGet(expr.view$id[i])$path, sep = '\t') %>% as.tibble()
  f <- f[,c("gene_id", "TPM")]
  colnames(f)[2] <- expr.view$sample[i]
  return(f)
})

# sanity check 
# lapply(tpm.dat, dim)

tpm.matrix <- tpm.dat %>%
  Reduce(function(df1, df2) left_join(df1, df2, by = "gene_id"), .) %>%
  as.matrix()

tpm.df <- tpm.dat %>%
  Reduce(function(df1, df2) left_join(df1, df2, by = "gene_id"), .) %>%
  as.data.frame()

# save(tpm.matrix, file = "TPM_mRNA_expression_matrix.RData")
# save(tpm.df, file = "TPM_mRNA_expression_df.RData")
# save(sample.map, file = "sample_map_df.RData")


