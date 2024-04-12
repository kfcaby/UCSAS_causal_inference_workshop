# ***********************************************
# Title       : propensity_blank.R
# Description : See propensity_score_model.R for 
# complete code
#
# Author      : Kevin Cummiskey
# Date        : April 12, 2024
# ***********************************************

#load libraries
library(tidyverse)
library(Lahman)
library(modelr)
library(MatchIt)


#Go to https://github.com/kfcaby/UCSAS_causal_inference_workshop
# and download the csv file in the data folder

# make sure you change file path below

# read in the data set
home_tied_2122 <- read_csv(file = "./data/tied_game_homehalf_2021_2022.csv")
