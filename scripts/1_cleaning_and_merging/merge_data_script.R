library(readr)
library(dplyr)
library(lubridate)
library(raster)
library(rasterVis)
library(stringr)
setwd("~/MS_Data_Science/Capstone")

# ndre_data <- data.frame(read_csv(file = './HydroSatML/data/ndre_local_data/localized_ndre_data_2.csv'))
ndre_data <- data.frame(read_csv(file = './HydroSatML/data/ndre_local_data/exact_ndre_data.csv'))
ndre_data <- transform(ndre_data, field = factor(field))
names(ndre_data) <- tolower(names(ndre_data))
ndre_data_sub <- subset(ndre_data, year(date) != 2009 & year(date) != 2010)
# high_error_idx <- which(ndre_data_sub$average_adjacent > 1.0)
high_error_idx <- which(ndre_data_sub$ndre_val > 1.0)
# ndre_data_sub[high_error_idx, c('average_adjacent', 'stdev_adjacent')] <- NA
ndre_data_sub[high_error_idx, 'ndre_val'] <- NA

ndre_data_sub <- na.omit(ndre_data_sub)

soilM <- data.frame(read_csv(file = './HydroSatML/data/soil_moisture/output_data/soil_moisture.csv'))
soilM <- transform(soilM, date = as.Date(as.character(date), format = '%Y-%m-%d'),
                   field = factor(field),
                   sensor_full_name = factor(sensor_full_name))
soilM$year <- year(soilM$date)

soil_prop <- read_csv('./HydroSatML/data/site_analysis/soil_properties/soil_properties_cleaned.csv')
soil_prop <- transform(soil_prop, field = factor(field))
soil_prop_ssc <- soil_prop[,c(1:18)]
soil_prop_ssc <- soil_prop_ssc[,-c(7,8,12,13,17,18)]
soil_prop_ssc <- na.omit(soil_prop_ssc)
soil_prop_ssc_long <- rbind(soil_prop_ssc,soil_prop_ssc, soil_prop_ssc, soil_prop_ssc, 
                            soil_prop_ssc, soil_prop_ssc)
soil_prop_ssc_long$year <- c(rep(2011, 48), rep(2012, 48), rep(2013, 48), rep(2014, 48), 
                             rep(2015, 48), rep(2016, 48))
soil_prop_ssc_long <- soil_prop_ssc_long[,-1]

#### create lagged dataframes of soilM
merge_df <- data.frame('orig_date' = ndre_soilM_weather_ssc_join$date,
                       'field' = ndre_soilM_weather_ssc_join$field,
                       'sensor' = ndre_soilM_weather_ssc_join$sensor)
date_vec <- ndre_soilM_weather_ssc_crop_join$date

####
# weather
####

weather <- read_csv('./HydroSatML/data/weather/weather_data_cleaned.csv')
names(weather)[2] <- 'field'
weather <- transform(weather, date = as.Date(as.character(date), format = '%Y-%m-%d'),
                     field = factor(field))
####
# crop stuff
####
crop <- read_csv('./HydroSatML/data/crop/crop_data_cleaned.csv')
crop <- crop[,-7]
names(crop)[2] <- 'field'
crop <- transform(crop, field = factor(field))


#### MERGING

ndre_soilM_join <- left_join(ndre_data_sub, soilM, by=c('field', 'sensor', 'date'))
ndre_soilM_weather_join <- left_join(ndre_soilM_join, weather, by=c('date', 'field'))
ndre_soilM_weather_join$year <- year(ndre_soilM_weather_join$date)

ndre_soilM_weather_ssc_join <- left_join(ndre_soilM_weather_join, soil_prop_ssc_long, 
                                         by=c('field', 'year', 'sensor'))

# ndre_soilM_weather_ssc_crop_join <- left_join(ndre_soilM_weather_ssc_join, crop,
#                                               by=c('field','date','sensor'))

# ndre_final_merge_with_lag <- left_join(ndre_soilM_weather_ssc_join, test, 
#                                        by=c('field','date','sensor'))
merge_df <- data.frame('orig_date' = ndre_soilM_weather_ssc_join$date,
                       'field' = ndre_soilM_weather_ssc_join$field,
                       'sensor' = ndre_soilM_weather_ssc_join$sensor)
date_vec <- ndre_soilM_weather_ssc_crop_join$date
lagged_df <- lagged_soilM_df(soilM, merge_df = merge_df)
A <- ndre_soilM_weather_ssc_join
B <- lagged_df

ndre_final_merge_with_lag <- cbind(A, B)
ndre_final_merge_with_lag <- ndre_final_merge_with_lag[,-c(27:29)]

joined_data <- ndre_final_merge_with_lag
row.names(joined_data) <- NULL


# remove all missing soil moisture
t = 1
idx <- c()
for(i in 1:nrow(joined_data)){
    if(all(is.na(joined_data[i,c(7:9)]))){
        idx[t] <- i
        t = t + 1
    }
}

# sub out the missing data
joined_data_sub <- joined_data[-idx, ]

# sub out depth 4 and depth 5
joined_data_sub <- joined_data_sub[,-c(10:11)]

# joined_data_sub <- transform(joined_data_sub, avg_soilM = rowMeans(c(depth_1, depth_2, depth_3), na.rm=T))
joined_data_sub$avg_soilM <- rowMeans(joined_data_sub[,c(7:8)], na.rm=T)
joined_data_sub$avg_soilM_l3 <- rowMeans(joined_data_sub[,c(25:27)], na.rm=T)
joined_data_sub$avg_soilM_l5 <- rowMeans(joined_data_sub[,c(28:30)], na.rm=T)
joined_data_sub$avg_soilM_l7 <- rowMeans(joined_data_sub[,c(31:33)], na.rm=T)
joined_data_sub$avg_clay <- rowMeans(joined_data_sub[,c(22:24)], na.rm = T)
joined_data_sub$avg_sand <- rowMeans(joined_data_sub[,c(16:18)], na.rm = T)
joined_data_sub$avg_silt <- rowMeans(joined_data_sub[,c(19:21)], na.rm = T)



idx <- c(which(joined_data_sub$avg_soilM == 0), which(is.na(joined_data_sub$avg_soilM)))
joined_data_sub <- joined_data_sub[-idx, ]

# joined_data_no_bare_soil <- subset(joined_data_sub, average_adjacent >= 0.40)
joined_data_no_bare_soil <- subset(joined_data_sub, ndre_val >= 0.40)
write_csv(x = joined_data_no_bare_soil, path = './HydroSatML/data/final_join_subbed_bare_soil_with_lag_40_EXACT_NDRE.csv')
