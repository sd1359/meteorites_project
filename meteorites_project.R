#reading the data into R script

library(tidyverse)
library(janitor)
library(assertr)

#Reading in the data
meteorite_data_raw <- read_csv("meteorite_landings.csv")

#Including assertive programming to ensure that the data has the variable names we expect (“id”, “name”, “mass (g)”, “fall”, “year”, “GeoLocation”).
stopifnot(names(meteorite_data_raw) %in% c("id", "name", "mass (g)", "fall", "year", "GeoLocation"))

#Changing the names of the variables to follow the snake_case format using clean_names function
meteorite_data <- meteorite_data_raw %>% 
  clean_names()

#Splitting the column GeoLocation into latitude and longitude.

meteorite_data <- meteorite_data %>% 
  separate(geo_location, c("latitude", "longitude"), sep = ", ") %>% 
  #Removing the first bracket from latitude data and the bracket at the end of the longitude data
  mutate(latitude = str_remove(latitude, pattern = "\\("), 
         longitude = str_remove(longitude, pattern = "\\)")) %>% 
  #Changing the new columns from characters to numeric
  mutate(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude))

#Checking the new columns are numeric
glimpse(meteorite_data)

#Checking for missing values in the data
meteorite_data %>% 
  summarise(across(.fns = ~sum(is.na(.x))))

#Replacing missing values with zeros for latitude and longitude columns
meteorite_data <- meteorite_data %>% 
  mutate(latitude = coalesce(latitude, 0),
         longitude = coalesce(longitude, 0))

#Checking if the NA's have been successfully removed in latitude column 
meteorite_data %>% 
  filter(is.na(latitude))

#Checking if the NA's have been successfully removed in longitude column
meteorite_data %>% 
  filter(is.na(longitude))

meteorite_data <- meteorite_data %>% 
  #Removing meteorites less than 1000g in weight from the data.
  filter(mass_g >= 1000) %>% 
  #Ordering the data by the year of discovery, with the latest discovery first.
  arrange(desc(year)) %>% 
  #Putting in checks using assertive programming to ensure latitude and longitude are valid values. (Latitude between -90 and 90, longitude between -180 and 180).
  verify(latitude >= -90 & latitude <= 90) %>% 
  verify(longitude >= -180 & longitude <= 180)

write_csv(meteorite_data, "meteorite_project.csv", path = "meteorite_project.csv")
