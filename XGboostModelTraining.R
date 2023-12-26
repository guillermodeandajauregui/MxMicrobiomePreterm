library(tidyverse)
library(tidymodels)

################################################################################
#read data ----

x <- vroom::vroom("data/main_data.txt")

x <- x %>% mutate(was_term = as_factor(was_term))
################################################################################

################################################################################
#split data ---- 

set.seed(123)

data_split <- initial_split(x, prop = 0.7, strata = was_term)

training_data <- training(data_split)
test_data <- testing(data_split)




################################################################################

################################################################################
#train model ---- 

recipe <- 
  recipe(was_term ~ ., data = training_data) %>%
  step_rm(specimen) %>%
  #step_dummy(all_nominal(), one_hot = TRUE) %>%
  step_center(all_numeric(), -all_outcomes()) %>%
  step_scale(all_numeric(), -all_outcomes())


xgb_model <- boost_tree(
  mode = "classification",
  trees = 100,          # Number of trees (you can adjust this)
  mtry = 5,             # Number of predictors to sample at each split (you can adjust this)
  min_n = 10,           # Minimum number of data points in terminal nodes (you can adjust this)
  tree_depth = 5,       # Maximum depth of each tree (you can adjust this)
  learn_rate = 0.1      # Learning rate (you can adjust this)
) %>%
  set_engine("xgboost") %>%
  set_mode("classification")


workflow <- workflow() %>%
  add_recipe(recipe) %>%
  add_model(xgb_model)

fit <- fit(workflow, data = training_data)

################################################################################

################################################################################
#test model ---- 

test_predictions <- predict(fit, new_data = test_data)

confusion_matrix <- table(Actual = test_data$was_term, Predicted = test_predictions$.pred_class)

################################################################################

################################################################################
#evaluate model ---- 

library(pROC)

# Calculate ROC curve
roc_curve <- roc(as.numeric(test_data$was_term), 
                 as.numeric(test_predictions$.pred_class)
                 )

# Plot the ROC curve
plot(roc_curve, print.auc = TRUE, main = "ROC Curve for Boosted Tree Model")

################################################################################


################################################################################
#save model ---- 

write_rds(x = fit, file = "xgboost_model.rds")

################################################################################