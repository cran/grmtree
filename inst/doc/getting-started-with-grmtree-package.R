## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----eval=F-------------------------------------------------------------------
# ## Install packages from CRAN repository
# install.packages(c("dplyr", "grmtree", "mirt", "psych"))

## ----message=FALSE, warning=FALSE---------------------------------------------
library(dplyr)        # For data manipulation
library(grmtree)      # For tree-based GRM DIF Test
library(mirt)         # For traditional GRM
library(psych)        # For psychometrics

## ----message=FALSE------------------------------------------------------------
## Load the data
data("grmtree_data", package = "grmtree")

## Take a glimpse at the data
glimpse(grmtree_data)

## ----warning=FALSE------------------------------------------------------------
## Create the response data (the 8 MOS-SS items)
response_data <- grmtree_data %>% 
  dplyr::select(MOS_Listen:MOS_Understand) %>% 
  mutate_at(vars(starts_with("MOS")), as.ordered)

## Create response as outcomes
response_data$resp <- data.matrix(response_data[, 1:8])

## ----eval=FALSE---------------------------------------------------------------
# ## Calculate the polychoric correlation of items
# polycorr_mos <- polychoric(response_data$resp, global=FALSE)$rho
# 
# ## Return the eigen values
# polycorr_eigen_mos <- eigen(polycorr_mos)$values
# round(polycorr_eigen_mos, 3)
# 
# ## Ratio of first and second eigen value
# mos_ratio <- round(round(polycorr_eigen_mos, 3)[1]/round(polycorr_eigen_mos, 3)[2],3)
# 
# ## Print the result
# mos_ratio
# 
# cat("The ratio of the first-to-second eigen value is", mos_ratio,
#     "which is >4 suggesting that the unidimensionality assumption is satisfied", "\n")

## ----eval=FALSE---------------------------------------------------------------
# ## Scree plot of eigen values
# plot(1:length(polycorr_eigen_mos), polycorr_eigen_mos,
#      type = "b", pch = 20, xlab = "", ylab = "Eigen values")

## ----eval=FALSE---------------------------------------------------------------
# ## Perform EFA with 1 factors
# efa_mos <- fa(response_data$resp, nfactors = 1, rotate = "varimax", fm = "mle")
# 
# ## Print the results
# summary(efa_mos)
# print(efa_mos, sort=TRUE)
# efa_mos$loadings
# 
# ## Visualizing factor structure using fa.diagram
# fa.diagram(efa_mos, main = "EFA Factor Structure")
# 
# ## Scree plot to visualize the number of factors
# fa.parallel(response_data$resp, fa = "fa")

## -----------------------------------------------------------------------------
## Create GRM
mos_grm <- mirt(data = response_data$resp, 
                model = 1,
                itemtype = "graded", SE = TRUE, method = "EM",
                verbose = FALSE)

## -----------------------------------------------------------------------------
## Get the coefficients
mos_coef <- coef(mos_grm, IRTpars = T, simplify = TRUE)
mos_coef

## Get the residuals
residuals(mos_grm, type = "Q3")

## Compute the M2 model fit statistic
M2(mos_grm, type = "C2")

## Infit and outfit statistics
mirt::itemfit(mos_grm, c('S_X2', 'infit'), method = 'EAP')

## Could also use method = 'ML'

## ----eval = FALSE-------------------------------------------------------------
# ## Plot the category response curves
# plot(mos_grm, type = 'trace')
# 
# ## Plot the test information
# plot(mos_grm, type = 'info')

## ----grmtree-process, echo=FALSE, out.width="75%", fig.align='center', fig.cap="GRMTree implementation process showing the four-step recursive partitioning approach for detecting differential item functioning"----
knitr::include_graphics("GRMTree.png")

## ----warning=FALSE------------------------------------------------------------

## Prepare the data
resp.data <- grmtree_data %>% 
  mutate_at(vars(starts_with("MOS")), as.ordered) %>% 
  mutate_at(vars(c(sex, residency, depressed,
                   Education, job, smoker,
                   multimorbidity)), as.factor) 

## Explore the data
head(resp.data)

## Check the structure of the data
glimpse(resp.data)

## Create response as outcomes
resp.data$resp <- data.matrix(resp.data[, 1:8])

## GRMTree control parameters with Benjamini-Hochberg
grm_control <- grmtree.control(
  minbucket = 350,
  p_adjust = "BH", alpha = 0.05)


## Fit the GRMTree model
mos_grmtree <- grmtree(resp ~ sex + age + bmi + Education + depressed +
                       residency + job + multimorbidity + smoker,  
                       data = resp.data,
                       control = grm_control)

## ----eval=FALSE---------------------------------------------------------------
# ## Bonferroni correction
# tree_bonf <- grmtree(response ~ covariate1 + covariate2, data = df,
#                     control = grmtree.control(p_adjust = "bonferroni"))
# 
# ## Hommel
# tree_bh <- grmtree(response ~ covariate1 + covariate2, data = df,
#                   control = grmtree.control(p_adjust = "hommel"))
# 
# ## Holm-Bonferroni
# tree_holm <- grmtree(response ~ covariate1 + covariate2, data = df,
#                     control = grmtree.control(p_adjust = "holm"))

## -----------------------------------------------------------------------------
## Print the tree model
print(mos_grmtree)
print(mos_grmtree, FUN = function(x) " *")

## -----------------------------------------------------------------------------
## Create the regions plot (by default)
plot(mos_grmtree)

## This also creates a regions plot
plot(mos_grmtree, type = "regions",  tnex = 2L)

## Create the histogram plot of the factor scores
plot(mos_grmtree, type = "histogram",  tnex = 2L)

## Create the profile plot with different options
plot(mos_grmtree, type = "profile", tnex = 2L, what = "threshold")
plot(mos_grmtree, type = "profile", tnex = 2L, what = "discrimination")
plot(mos_grmtree, type = "profile", tnex = 2L, what = "item")

## -----------------------------------------------------------------------------
## Return the names of the covariates to know the position of age
names(mos_grmtree$data)

## Rename the age to Age (Uncomment the code below and change to the correct name)
#names(mos_grmtree$data)[3] <- "Age"

## Create the regions plot (by default)
plot(mos_grmtree)

## -----------------------------------------------------------------------------
## Extract and print the threshold parameters
thresholds <- threshpar_grmtree(mos_grmtree)
print(thresholds)

## Extract and print the discrimination parameters
discriminations <- discrpar_grmtree(mos_grmtree)
print(discriminations)

## Extract and print the item parameters
itemspars <- itempar_grmtree(mos_grmtree)
print(itemspars)

