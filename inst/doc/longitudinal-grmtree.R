## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----eval=FALSE---------------------------------------------------------------
# ## Install packages from CRAN repository
# install.packages(c("dplyr", "grmtree", "mirt"))

## ----message=FALSE, warning=FALSE---------------------------------------------
library(dplyr)        # For data manipulation
library(grmtree)      # For the Longitudinal GRMTree
library(mirt)         # For the underlying IRT estimation

## ----message=FALSE------------------------------------------------------------
## Load the data
data("grmtree_long_data", package = "grmtree")

## Take a glimpse at the data
glimpse(grmtree_long_data)

## -----------------------------------------------------------------------------
## Baseline item names
items_t1 <- c("MOS_Listen", "MOS_Info", "MOS_Advice_Crisis", "MOS_Confide",
              "MOS_Advice_Want", "MOS_Fears", "MOS_Personal", "MOS_Understand")

## Follow-up item names (same order, with the _year1 suffix)
items_t2 <- paste0(items_t1, "_year1")

## Build the wide-format data
ld <- prepare_longitudinal_data(
  data       = grmtree_long_data,
  items_t1   = items_t1,
  items_t2   = items_t2,
  covariates = c("sex", "age", "residency", "job",
                 "education", "comorbidity_count", "ever_smoker")
)

## The response matrix lives in the resp_wide column (16 = 2 x 8 columns)
dim(ld$resp_wide)

## ----eval=FALSE---------------------------------------------------------------
# ## Fit the Longitudinal GRMTree
# tree <- longitudinal_grmtree(
#   resp_wide ~ sex + age + residency + job +
#     education + comorbidity_count + ever_smoker,
#   data    = ld,
#   n_items = 8,
#   control = grmtree.control(minbucket = 200, p_adjust = "bonferroni", alpha = 0.05)
# )
# 
# ## Print the tree structure
# print(tree)

## ----eval=FALSE---------------------------------------------------------------
# ## Phase 2: characterize response shift
# rs <- rs_characterize(
#   tree,
#   p_adjust        = "fdr",          # item-level correction within nodes
#   global_p_adjust = "bonferroni",   # omnibus correction across nodes
#   rs_threshold    = 0.3             # RS-type classification threshold
# )
# 
# ## View the results
# print(rs)

## ----eval=FALSE---------------------------------------------------------------
# rs$global       # one row per terminal node (omnibus results)
# rs$item_level   # one row per item per RS-detected node
# rs$parameters   # constrained and unconstrained item parameters per node

## ----eval=FALSE---------------------------------------------------------------
# ## Short item labels for display
# mos_labels <- c("Listen", "Info", "Crisis", "Confide",
#                 "Advice", "Fears", "Personal", "Understand")
# 
# ## Annotated tree with RS results in the terminal nodes
# plot_rs_tree(tree, rs, item_labels = mos_labels)
# 
# ## Standalone item-level RS heatmap
# plot_rs_heatmap(rs, item_labels = mos_labels)
# 
# ## Heatmap with chi-squared values shown in the cells
# plot_rs_heatmap(rs, item_labels = mos_labels, show_chi2 = TRUE)

## ----eval=FALSE---------------------------------------------------------------
# ## Region plot of the tree with item names
# plot(tree, names = mos_labels, tnex = 2L)

## ----eval=FALSE---------------------------------------------------------------
# ## Threshold parameters (8 items per node)
# threshpar_longitudinal_grmtree(tree)
# 
# ## Discrimination parameters (from the a1 column)
# discrpar_longitudinal_grmtree(tree)
# 
# ## Combined item parameters (discrimination + thresholds)
# itempar_longitudinal_grmtree(tree)
# 
# ## Latent trait summary per node (mu_T2, variance, T1-T2 correlation)
# latentpar_longitudinal_grmtree(tree)

## ----eval=FALSE---------------------------------------------------------------
# ## Factor scores per terminal node
# scores <- fscores_longitudinal_grmtree(tree)
# head(scores[["3"]])   # Theta_T1 and Theta_T2 for the older subgroup

## ----eval=FALSE---------------------------------------------------------------
# ## Augment the original data with node assignments and factor scores
# scored <- generate_node_scores_dataset(tree, data = ld)
# glimpse(scored)   # all original columns + node + Theta_T1 + Theta_T2

