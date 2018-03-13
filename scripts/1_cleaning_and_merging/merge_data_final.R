library(readr)
library(dplyr)
library(lubridate)
library(raster)
library(rasterVis)
library(stringr)
setwd("~/Desktop/HydroSatML/")

# NDRE data input and cleaning
ndre_data <- data.frame(read_csv(file = './data/2_cleaned/ndre_local_data/exact_ndre_data.csv'))
ndre_data <- transform(ndre_data, field = factor(field))
names(ndre_data) <- tolower(names(ndre_data))
ndre_data_sub <- subset(ndre_data, year(date) != 2009 & year(date) != 2010)
high_error_idx <- which(ndre_data_sub$ndre_val > 1.0)
ndre_data_sub[high_error_idx, 'ndre_val'] <- NA
ndre_data_sub <- na.omit(ndre_data_sub)

# Soil moisture data input
soilM <- data.frame(read_csv(file = './data/2_cleaned/soil_moisture.csv'))
soilM <- transform(soilM, date = as.Date(as.character(date), format = '%m/%d/%y'),
                   field = factor(field),
                   sensor_full_name = factor(sensor_full_name))
soilM$year <- year(soilM$date)

# soil physical properties input
soil_prop <- read_csv('./data/2_cleaned/soil_properties_cleaned.csv')
soil_prop <- transform(soil_prop, field = factor(field))
soil_prop_ssc <- soil_prop[, c(1:18)]
soil_prop_ssc <- soil_prop_ssc[, -c(7, 8, 12, 13, 17, 18)]
soil_prop_ssc <- na.omit(soil_prop_ssc)
soil_prop_ssc_long <- rbind(soil_prop_ssc, soil_prop_ssc, soil_prop_ssc, soil_prop_ssc,
                            soil_prop_ssc, soil_prop_ssc)
soil_prop_ssc_long$year <- c(rep(2011, 48), rep(2012, 48), rep(2013, 48), rep(2014, 48),
                             rep(2015, 48), rep(2016, 48))
soil_prop_ssc_long <- soil_prop_ssc_long[, -1]


#### merging
ndre_soilM_join <- left_join(ndre_data_sub, soilM, by=c('field', 'sensor', 'date'))
ndre_soilM_weather_join <- left_join(ndre_soilM_join, weather, by=c('date', 'field'))
ndre_soilM_weather_join$year <- year(ndre_soilM_weather_join$date)

ndre_soilM_weather_ssc_join <- left_join(ndre_soilM_weather_join, soil_prop_ssc_long, 
                                         by=c('field', 'year', 'sensor'))

joined_data_no_bare_soil <- subset(joined_data_sub, ndre_val >= 0.40)
write_csv(x = joined_data_no_bare_soil, path = './HydroSatML/data/final_join_subbed_bare_soil_with_lag_40_EXACT_NDRE.csv')
