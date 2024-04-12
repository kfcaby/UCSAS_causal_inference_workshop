# ***********************************************
# Title       : propensity_score_models.R
# Description : Fits various propensity score models
# to estimate the effect of bunting in tied extra inning
# games - presented at UCSAS 2024
#
# Author      : Kevin Cummiskey
# Date        : April 12, 2024
# ***********************************************

#load libraries
library(tidyverse)
library(Lahman)
library(modelr)
library(MatchIt)


# read in the data set
home_tied_2122 <- read_csv(file = "./data/tied_game_homehalf_2021_2022.csv")


#fit crude model
crude_model <- glm(runs_scored > 0 ~ bunt_fl, family = "binomial",
                   data = home_tied_2122)

summary(crude_model)

exp(crude_model$coefficients)

#simple prop model
prop_model <- glm(bunt_fl ~ OPS + SH_rate_bat, 
                  data = home_tied_2122,
                  family = 'binomial')

summary(prop_model)


#add propensity scores to the original data frame
home_tied_2122 <- home_tied_2122 %>% 
  add_predictions(prop_model, var = "propensity_bunt" , type = 'response')



#visualize propensity scores
home_tied_2122 %>% 
  ggplot(aes(x = propensity_bunt, fill = bunt_fl)) +
  geom_histogram() 



#propensity score matching
# Austin - 0.2 * the standard deviation of the logit of the 
# propensity score

match = matchit(bunt_fl ~ OPS + SH_rate_bat, data = home_tied_2122,
                method = 'nearest', distance = 'logit', caliper = 0.2)

summary(match)

matched_data = match.data(match)


model_matched = glm(runs_scored > 0 ~ bunt_fl, data = matched_data,
                    family = 'binomial')
summary(model_matched)


#calculate inverse probability weights
home_tied_2122 <- home_tied_2122 %>% 
  mutate(ip_weight = ifelse(bunt_fl, 1/propensity_bunt, 1/(1-propensity_bunt)))

#fit outcome model with clipping
model_ipw_trim <- home_tied_2122 %>% 
  filter(propensity_bunt > 0.1, propensity_bunt < 0.9) %>% 
  glm(runs_scored > 0 ~ bunt_fl + OPS + SH_rate_bat, data = ., 
      family = 'binomial',
      weight = ip_weight) 

summary(model_ipw_trim)

