library(yaml)
library(tidyverse)
library(glue)
library(rprojroot)

root_dir <- find_root(is_rstudio_project, thisfile())
data_dir <- file.path(root_dir, "data")

format_data <- function() {
  data_file <- file.path(data_dir, "tcga_brca_cluster_inputs.RData")
  
  if (!(file.exists(data_file))) {
    load(file.path(data_dir, "tcga_brca_expr_norm_df.RData"))
    load(file.path(data_dir, "tcga_brca_clinical_df.RData"))
    load(file.path(data_dir, "tcga_brca_cdr_clinical_df.RData"))
    
    x1 <- names(brca_expr_norm_df)[2:ncol(brca_expr_norm_df)]
    x2 <- brca_clinical_df[["bcr_patient_barcode"]]
    x3 <- brca_cdr_clinical_df[["bcr_patient_barcode"]]
    sample.names <- intersect(intersect(x1, x2), x3)
    sample.names <- sort(sample.names)
    
    I <- match(sample.names, names(brca_expr_norm_df))
    if(any(is.na(I))) stop("Missing samples")
    if(min(I) < 2) stop("missing gene id column")
    I <- c(1, I)
    brca_expr_norm_df <- brca_expr_norm_df[,I]
    
    I <- match(sample.names, brca_clinical_df[["bcr_patient_barcode"]])
    brca_clinical_df <- brca_clinical_df[I,]
    
    gene.name <- brca_expr_norm_df[,1]
    X <- as.matrix(brca_expr_norm_df[,2:ncol(brca_expr_norm_df)])
    X.log <- log(X+1, 2)
    
    NUM.GENES <- 500
    v <- apply(X, 1, var)
    O <- order(v, decreasing=TRUE)
    X.log.sub <- X.log[O[1:NUM.GENES],]
    
    I.sample <- seq(1, ncol(X), 10)

    x <- X.log.sub
    means <- apply(x, 1, mean)
    x <- sweep(x, 1, means)
    x <- t(apply(x, 1, function(x) {
      V.0 <- var(x); 
      M.0 <- mean(x); 
      (x-M.0)*sqrt(1/V.0) + M.0 
    }))
    X.norm <- x
    rev <- X.norm[nrow(X.norm):1, I.sample]
    
    clin <- brca_clinical_df[I.sample, ]
    save(list = c("rev", "clin"), file = data_file)
  } else {
    load(data_file)
  }

  list(rev = rev, clin = clin)
}


score_submission <- function(submission_filename) {

  answers <- yaml.load_file(submission_filename)
  dist.method <- answers$distance_metric
  clust.method <- answers$cluster_method
  NUM.CLUSTERS <- answers$num_clusters
  p_value <- answers$p_value
  
  submission_data <- format_data()
  rev <- submission_data$rev
  clin <- submission_data$clin
  
  if(dist.method == "pearson") {
    row.dist <- as.dist(1-cor(t(rev), method=dist.method))
    col.dist <- as.dist(1-cor(rev, method=dist.method))
  } else {
    row.dist <- dist(rev, method=dist.method)
    col.dist <- dist(t(rev), method=dist.method)
  }
  rc <- hclust(row.dist, method=clust.method)
  cc <- hclust(col.dist, method=clust.method)
  
  cluster <- cutree(cc, k=NUM.CLUSTERS)
  
  outcome <- "breast_carcinoma_estrogen_receptor_status"
  values <- sort(unique(clin[[outcome]]))
  uniq.clust <- sort(unique(cluster))

  counts <- matrix(0, nrow=length(values), ncol=length(uniq.clust))
  for(i in 1:length(values)) {
    for(j in 1:length(uniq.clust)) {
      I1 <- clin[[outcome]] == values[i]
      I2 <- cluster == uniq.clust[j]
      counts[i, j] <- sum(I1&I2)
    }
  }
  
  res <- chisq.test(counts)
  
  pval_match <- all_equal(
    round(res$p.value, digits = 4),
    round(answers$p_value, digits = 4)
  ) %>%
    isTRUE()
  
  if (pval_match) {
    msg <- glue("You got a p-value of {p}. That matched what I found for ",
                "the same combination of distance metric and clustering ", 
                "method.",
                p = round(answers$p_value, digits = 5))
    if (res$p.value <= 0.01) {
      msg <- paste(msg, "That's pretty significant — you're a p-hacking",
                   "champion!")
    } else if (between(res$p.value, 0.01, 0.05)) {
      msg <- paste(msg, "Significant, but not extreme — a good example", 
                   "of a result that deserves some follow-up analysis.")
    } else {
      msg <- paste(msg, "p > 0.05 isn't *technically* significant. Were you",
                   "able to find any combinations with stronger results?")
    }
  } else {
    msg <- glue("Hmm... you found a p-value of {p}, but I calculated ",
                "{p0} for that distance metric and clustering method. ", 
                "Are you sure you copied the right value?", 
                p = round(answers$p_value, digits = 5), 
                p0 = round(res$p.value, digits = 5))
  }
  
  answers["comment"] <- msg
  answers
}
