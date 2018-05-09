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

