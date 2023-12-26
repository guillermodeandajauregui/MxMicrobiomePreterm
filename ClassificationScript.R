library(tidyverse)
library(tidymodels)

################################################################################
#read data ----
# input should be MALIAMPI-like phylotype_relabd abundance
# including only the phylotypes in the "selected features" file 

x <- "path/to/datamatrix"

################################################################################
#read model ----

xgboost_model <- readRDS("model/xgboost_model.rds")

predictions <- predict(loaded_xgboost_model, newdata = x)

