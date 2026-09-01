## ----setup, include=FALSE-----------------------------------------------------

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----eval=F-------------------------------------------------------------------
# ## Install packages from CRAN repository
# install.packages(c("dplyr", "grmtree"))

## ----message=FALSE, warning=FALSE---------------------------------------------
library(dplyr)        # For data manipulation
library(grmtree)      # For tree-based GRM DIF Test

## ----message=FALSE------------------------------------------------------------
## Load the data
data("grmtree_data", package = "grmtree")

## Take a glimpse at the data
glimpse(grmtree_data)

## Prepare the data
resp.data <- grmtree_data %>% 
  mutate_at(vars(starts_with("MOS")), as.ordered) %>% 
  mutate_at(vars(c(sex, residency, depressed,
                   Education, job, smoker,
                   multimorbidity)), as.factor) 

## Note: Partitioning variables must be factor/numeric (character columns are coerced automatically, but converting yourself is cleaner).

## Explore the data
head(resp.data)

## Check the structure of the data
glimpse(resp.data)

## Create response as outcomes
resp.data$resp <- data.matrix(resp.data[, 1:8])

## -----------------------------------------------------------------------------
## Get help on the control parameter
# ?grmforest.control

## GRMTree control parameters with Benjamini-Hochberg 
grm_control <- grmtree.control(
  minbucket = 350,
  p_adjust = "BH", alpha = 0.05)

## Define the forest control parameters
p <- 9

forest_control <- grmforest.control(
  n_tree = 3, # Number of trees (Reduced for vignette build time)
  sampling = "subsample",  # subsample method; bootstrap also available
  sample_fraction = 0.632,
  mtry = ceiling(sqrt(p)),  # Usually the square root of the number of covariates
  control = grm_control,
  remove_dead_trees = TRUE, # Remove any null GRMTree
  seed = 123,
  n_cores = 4            # Parallel now works (PSOCK/Windows included)
)

## ----eval=FALSE---------------------------------------------------------------
# ## Fit the GRM forest
# mos_forest <- grmforest(
#   resp ~ sex + age + bmi + Education +
#   residency + depressed + job + multimorbidity + smoker,
#   data = resp.data,
#   control = forest_control
# )
# 
# ## Get the summary of the fitted forest
# print(mos_forest)
# 
# ## Plot a tree in the forest
# plot(mos_forest$trees[[1]])

## ----eval=FALSE---------------------------------------------------------------
# ## Calculate the variable importance
# importance <- varimp(mos_forest, seed = 123, verbose = T)
# 
# ## Print the result of the variable importance
# print(importance)

## ----eval=FALSE---------------------------------------------------------------
# ## Plot the variable importance scores (ggplot is the default)
# plot(importance)
# 
# ## Plot onlt the top 5 importance variables
# plot(importance, xlab = "", top_n = 5)
# 
# ## Plot the base R version
# plot(importance, use_ggplot = FALSE)
# 
# ## Custom colors
# plot(importance, col = c("green", "red"))
# 
# ## Rename the variable names in the order from the variable importance result
# names(importance) <- c("Age", "Smoking Status", "BMI",
#                        "Multimorbidity", "Sex", "Education",
#                        "Residency", "Depression", "Employment")
# 
# ## Now create the plot with informative names
# plot(importance)

