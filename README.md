# Meteorites Project

## Analysing Data from NASA on Meteorites Found up to 2013

## 1.1 The .R File
The objective of this project was to perform analysis on data obtained from NASA on meteorites found up to the year 2013. 
Raw Data source:- https://www.kaggle.com/nasa/meteorite-landings

The main points of interest which were investigated are outlined below:

1. The names and years found for the 10 largest meteorites in the data.
2. The average mass of meteorites that were recorded falling, vs. those which were just found.
3. The number of meteorites in each year, for every year since 2000.

Firstly, I created a .R file to clean the data by writing the code below. This intial step was taken to ensure the data was in the correct format in order to perform analysis. The names in the data were converted to snake_case format, the GeoLocation column was split into latitude and longitude columns and missing values in these columns were replaced with zero values. Assertive programming was also used at the beginning of the code in order to signal an error message if the variable names differed from those expected.

A breakdown on the function of each piece of code can be seen below:

###Reading in the raw data from NASA
`meteorite_data_raw <- read_csv("meteorite_landings.csv")`

### Assertive Programming
Ensuring that the data has the variable names expected (“id”, “name”, “mass (g)”, “fall”, “year”, “GeoLocation”).

`stopifnot(names(meteorite_data_raw) %in% c("id", "name", "mass (g)", "fall", "year", "GeoLocation"))`

### snake_case Format
I changed the names of the variables to follow the snake_case format by using the clean_names function
`meteorite_data <- meteorite_data_raw %>% 
  clean_names()`

### Splitting the column "GeoLocation" into latitude and longitude.

`meteorite_data <- meteorite_data %>% 
  separate(geo_location, c("latitude", "longitude"), sep = ", ") %>%` 
  
### Removing brackets from the latitude and longitude data
  `mutate(latitude = str_remove(latitude, pattern = "\\("), 
         longitude = str_remove(longitude, pattern = "\\)")) %>%`
         
### Changing the new "latitude" and "longitude" columns from characters to numeric
`  mutate(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude))`
  

### Checking for missing values in the data
`meteorite_data %>% 
summarise(across(.fns = ~sum(is.na(.x))))
`
### Replacing missing values with zeros for latitude and longitude columns
`meteorite_data <- meteorite_data %>% 
  mutate(latitude = coalesce(latitude, 0),
         longitude = coalesce(longitude, 0))`

### Checking if the NA's have been successfully removed in latitude column  
  `meteorite_data %>% filter(is.na(latitude))`

### Checking if the NA's have been successfully removed in longitude column
  `filter(is.na(longitude))`

### Removing meteorites less than 1000g in weight from the data, then ordering the data by the year of discovery.
 `meteorite_data <- meteorite_data %>% 
  filter(mass_g >= 1000) %>% arrange(desc(year)) %>%`
  
### Putting in checks using assertive programming to ensure latitude and longitude are valid values. (Latitude between -90 and 90, longitude between -180 and 180).
`verify(latitude >= -90 & latitude <= 90) %>% 
verify(longitude >= -180 & longitude <= 180)`

### Writing the data to a csv file named meteorite_project
`write_csv(meteorite_data, "meteorite_project.csv", path = "meteorite_project.csv")`

## 1.2 The .Rmd File
The .Rmd file was created to display information on the following points:

1. The names and years found for the 10 largest meteorites in the data.
2. The average mass of meteorites that were recorded falling, vs. those which were just found.
3. The number of meteorites in each year, for every year since 2000.

###Reading the cleaned meteorite data into R
`meteorite_project <- 
read_csv("meteorite_project.csv") %>%`

###Finding the names and years found for the 10 largest meteorites in the data.
  `ten_largest <- meteorite_project %>% 
  select(name, mass_g, year) %>% 
  slice_max(mass_g, n = 10)`

###Finding the average mass of meteorites that were recorded falling, vs. those which were just found.
`avg_mass_fell <- meteorite_project %>% 
  group_by(fall) %>% 
  summarise(mass_g = mean(mass_g))`

### Finding the number of meteorites in each year, for every year since 2000.
`meteorites_year <- meteorite_project %>% 
  filter(year >= 2000) %>% 
  group_by(year) %>% 
  summarise(meteorite_count = n())`
 
