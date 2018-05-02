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
sample.map <- sample.map %>% 
  mutate(experimentalCondition = str_replace_all(
    experimentalCondition, " Acid", "Acid"
  )) %>%
  separate(experimentalCondition,
           into = c("stiffness","stiffness_units", "surface"),
           remove = FALSE, extra = "merge", fill = "left") %>%
  mutate(
    surface = case_when(
      surface %in% c("Collagen", "Fibronectin") ~ experimentalCondition,
      TRUE ~ surface
    ),
    stiffness_units = ifelse(is.na(stiffness), NA, stiffness_units)
  ) %>%
  separate(surface, into = c("surface", "laminate")) %>%
  mutate(
    stiffness = parse_number(stiffness),
    stiffness_units = str_trim(stiffness_units),
    stiffness_norm = case_when(
      stiffness_units == "Pa" ~ stiffness / 1000,
      TRUE ~ stiffness
    )
  )

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

save(tpm.matrix, file = "TPM_mRNA_expression_matrix.RData")
save(sample.map, file = "sample_map_df.RData")

