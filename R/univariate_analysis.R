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
p_load("limma")
p_load("glmnet")
p_load("doMC")
p_load("doParallel")
p_load("corpcor")

#  --------------------------------------------------------
options(stringsAsFactors = FALSE)
registerDoParallel(detectCores() - 2)
# --------------------------------------------------------
synLogin()

# load("TPM_mRNA_expression_df.RData")
# load("sample_map_df.RData")
# load("summary_motility_df.RData")

load(synGet("syn12124760")$path)
load(synGet("syn12124757")$path)
load(synGet("syn12124759")$path)


rownames(tpm.df) <- tpm.df$gene_id
tpm.df <- tpm.df[, -1]
tpm.df <- log2(tpm.df + 1)
tpm.df <- as.data.frame(t(tpm.df))

tpm.var <- apply(tpm.df, 2, var)
summary(tpm.var)
tpm.var >= 0.2
tpm.df <- tpm.df[,tpm.var >= 0.2]
dim(tpm.df)

# --------------------------------------------------------
# PCA and QC 
# --------------------------------------------------------
pc <- prcomp(t(tpm.df), scale.=T, center = T)
summary(pc)

plotdata <- data.frame(sample = rownames(pc$rotation),
                       PC1 = pc$rotation[,1],
                       PC2 = pc$rotation[,2])

covars <- sample.map[, c("sample", "catalogNumber", "cellType", "experimentalCondition", "tumorType")]
plotdata <- left_join(plotdata, covars, by = 'sample')

ggplot(plotdata, aes(x = PC1, y = PC2)) + 
  geom_point(aes(color = experimentalCondition, shape = catalogNumber)) +
  theme_bw() + theme(legend.position = "right") 

boxplot(t(tpm.df), col = "darkslategray4", main = "log2(TPM + 1) Transformed TPMs with Variance >= 0.2")
# --------------------------------------------------------
ggplotRegression <- function(fit){
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "darkslategray4") +
    labs(title = paste("Adj R2 = ", round(signif(summary(fit)$adj.r.squared, 5), 4),
                       "Intercept =", round(signif(fit$coef[[1]], 5), 4),
                       " Slope =", round(signif(fit$coef[[2]], 5), 4),
                       " P =", round(signif(summary(fit)$coef[2,4], 5), 4)))
}
#  --------------------------------------------------------
# subset motility by available expression data 
motility <- summary.motility.df[which(summary.motility.df$catalogNumber %in% unique(sample.map$catalogNumber)), ]
motility.and.mapping <- left_join(motility, sample.map, by = c("catalogNumber" = "catalogNumber", "experimentalCondition" = "experimentalCondition"))

#  --------------------------------------------------------
# splice data by metric by motility 
# "end_to_end_distance_um" "total_distance_um"    "speed_um_over_hr"
#  --------------------------------------------------------
ete <- motility.and.mapping[which(motility.and.mapping$summary_metrics %in% "end_to_end_distance_um"), c("average_value", "sample")]
ete <- ete[match(rownames(tpm.df), ete$sample), ]
ete <- ete[, -2]
colnames(ete) <- "average_value_end_to_end_distance_um"
rownames(ete) <- rownames(tpm.df)

td <- motility.and.mapping[which(motility.and.mapping$summary_metrics %in% "total_distance_um"), c("average_value", "sample")]
td <- td[match(rownames(tpm.df), td$sample), ]
td <- td[, -2]
colnames(td) <- "average_value_total_distance_um"
rownames(td) <- rownames(tpm.df)

s <- motility.and.mapping[which(motility.and.mapping$summary_metrics %in% "speed_um_over_hr"), c("average_value", "sample")]
s <- s[match(rownames(tpm.df), s$sample), ]
s <- s[, -2]
colnames(s) <- "average_value_speed_um_over_hr"
rownames(s) <- rownames(tpm.df)

# average.metrics <- as.data.frame(cbind(ete, td, s))
# rownames(average.metrics) <- rownames(tpm.df)
# dat <- as.data.frame(cbind(average.metrics, tpm.df))

#  --------------------------------------------------------
tpm.df <- as.data.frame(tpm.df)
ete <- as.data.frame(ete)
td <- as.data.frame(td)
s <- as.data.frame(s)

#  --------------------------------------------------------
pvals.ete <- as.data.frame(unlist(lapply(seq_along(colnames(tpm.df)), function(i){
  dat <- cbind(tpm.df[,i], ete)
  colnames(dat)[1] <- colnames(tpm.df)[i]
  fm <- paste(colnames(dat)[2] , colnames(dat)[1] , sep = " ~ ")
  fit <- lm(formula = fm , data = dat)
  pval <- summary(fit)$coefficients[2, 4]
  return(pval)
})))
colnames(pvals.ete) <- "pvals"
rownames(pvals.ete) <- names(tpm.df)

#  --------------------------------------------------------
pvals.td <- as.data.frame(unlist(lapply(seq_along(colnames(tpm.df)), function(i){
  dat <- cbind(tpm.df[,i], td)
  colnames(dat)[1] <- colnames(tpm.df)[i]
  fm <- paste(colnames(dat)[2] , colnames(dat)[1] , sep = " ~ ")
  fit <- lm(formula = fm , data = dat)
  pval <- summary(fit)$coefficients[2, 4]
  return(pval)
})))
colnames(pvals.td) <- "pvals"
rownames(pvals.td) <- names(tpm.df)

#  --------------------------------------------------------
pvals.s <- as.data.frame(unlist(lapply(seq_along(colnames(tpm.df)), function(i){
  dat <- cbind(tpm.df[,i], s)
  colnames(dat)[1] <- colnames(tpm.df)[i]
  fm <- paste(colnames(dat)[2] , colnames(dat)[1] , sep = " ~ ")
  fit <- lm(formula = fm , data = dat)
  pval <- summary(fit)$coefficients[2, 4]
  return(pval)
})))
colnames(pvals.s) <- "pvals"
rownames(pvals.s) <- names(tpm.df)

#  --------------------------------------------------------
par(mfrow=c(1,3))
hist(pvals.ete$pvals, xlab='average_value_end_to_end_distance_um ~ geneID_i', breaks=200, col = 'lightblue', main = '')
hist(pvals.td$pvals, xlab='average_value_total_distance_um ~ geneID_i', breaks=200, col = 'lightblue', main = '')
hist(pvals.s$pvals, xlab='average_value_speed_um_over_hr ~ geneID_i', breaks=200, col = 'lightblue', main = '')
dev.off()

lm.avg.metric.pvals <- as.data.frame(cbind(pvals.ete, pvals.td, pvals.s))
colnames(lm.avg.metric.pvals) <- c('average_value_end_to_end_distance_um', 'average_value_total_distance_um', 'average_value_speed_um_over_hr')
# save(lm.avg.metric.pvals, file = 'univariate_analysis_geneid_over_avg_metric_pvals.RData')
# file <- File(path='univariate_analysis_geneid_over_avg_metric_pvals.RData', parentId='syn12124756')
# file <- synStore(file)