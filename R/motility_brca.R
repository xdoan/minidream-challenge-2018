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

if (fs::file_exists("data/summary_motility_df.RData")) {
  load("data/summary_motility_df.RData")
} else {
  
  
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
  summary.motility.df <- summary.motility.df %>% 
    filter(cellLine %in% c("T-47D", "MDA-MB-231")) %>%
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
  save(summary.motility.df, file = "data/summary_motility_df.RData")
}

# ---------------------------------------------------------
p <- summary.motility.df %>%
  arrange(surface, stiffness_norm, laminate) %>% 
  replace_na(list(stiffness_norm = "NA", laminate = "NA")) %>% 

  ggplot(aes(x = cellLine, y = average_value)) +
  geom_col(aes(fill = laminate, alpha = stiffness_norm), 
           position = position_dodge(0.9)) +
  geom_errorbar(
    aes(ymin = average_value - standard_error, 
        ymax = average_value + standard_error, 
        color = laminate, 
        alpha = stiffness_norm), 
    size = 0.5, width = 0.25, position = position_dodge(0.9)
  ) +
  scale_alpha_manual("stiffness [kPa]", values = c(0.3, 1, 1)) +
  scale_color_manual(values = c("black", "black", "black")) +
  scale_fill_brewer(palette = "Set1") +
  facet_grid(summary_metrics ~ surface, scales = "free_y") +
  labs(title = "Average motility measures vs. surface") +
  xlab("cell line") +
  ylab("") +
  theme_bw()
p
ggsave("pson-celllines_breastcancer_motility-summary.png", p, 
       width = 17.5, height = 10, units = "cm", scale = 2)
