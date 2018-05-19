# Data description

## PS-ON Cell Line data

### All cancer types

#### *Recommended data*

+ **`pson_sample_map_and_colors.RData`** 
    + `sample_map_df` [63 observations (cell lines) x 15 variables]: sample info dataframe for all cell lines and experimental conditions, with Synapse IDs for motility and expression data files
+ **`pson_expr_tpm_df.RData`**
    + `pson_expr_tpm_df` [56632 observations (genes) x 64 variables (63 samples + `gene_id`)]: TPM expression data for all genes, cell lines, and conditions
+ **`pson_expr_gene_info.RData`**
    + `gene_df` [56908 observations (genes) x 5 variables (IDs and annotations)]: dataframe with basic info for all genes in the PS-ON expression data (mapping based on GRCh38)

+ **`pson_motility_tidy_df.RData`**
    + `pson_motility_tidy_df` [186 observations x 20 variables]: dataframe with sample info from `sample_map_df` plus motility summary data for 9 cell lines, 7 conditions, 3 motility summary metrics (should be 189 rows, but 3 data points missing); *includes scaled and centered motility values*
    + `diagnosis_colors` [length 6 vector]: named character vector of hexidecimal color strings representing palette for PS-ON diagnoses (cancer types)

#### *Other data*

+ **`pson_expr_tpm_mat.RData`**
    + `pson_expr_tpm_mat` [56632 rows x 63 columns]: matrix with same data as `pson_expr_tpm_df` (gene IDs as rownames) 
+ **`pson_motility_summary_df.RData`**
    + `pson_expr_summary_df`: [186 observations x 20 variables]: dataframe with sample info from `sample_map_df` plus motility summary data for 9 cell lines, 7 conditions, 3 motility summary metrics (should be 189 rows, but 3 data points missing)

## TCGA Patient Data

### Breast cancer only

+ **`tcga_brca_clinical_df.RData`** (and `tcga_brca_clinical_df.tsv`)
    + `brca_clinical_df` [1083 observations (samples) x 45 variables]: sample info (clinical outcomes data) dataframe for TCGA breast cancer patients
+ **`tcga_brca_cdr_clinical_df.RData`** (and `tcga_brca_cdr_clinical_df.tsv`)
    + `brca_cdr_ clinical_df` [1082 observations (samples) x 22 variables]: TCGA-Clinical Data Resource (CDR) based sample info (clinical outcomes data) dataframe for TCGA breast cancer patients
+ **`tcga_brca_expr_norm_df.RData`** (and `tcga_brca_expr_norm_df.tsv`)
    + `brca_expr_norm_df` [18351 observations (genes) x 1084 variables (1083 samples + Ensembl `gene_id`)]: batch-corrected, normalized expression data for all genes in TCGA BRCA samples
+ **`tcga_brca_expr_gene_info.RData`** (and `tcga_brca_expr_gene_info.tsv`)
    + `gene_df` [18351 observations (genes) x 5 variables (IDs and annotations)]: dataframe with basic info for all genes in the TCGA expression data (mapping based on GRCh37/hg19)
    
#### *Other data*

+ **`tcga_brca_expr_norm_mat.RData`**
    + `brca_expr_norm_mat` [18351 rows x 1083 columns]: matrix with same data as `brca_expr_norm_df` (gene IDs as rownames) 
