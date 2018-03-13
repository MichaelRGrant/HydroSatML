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
high_error_idx <- which(ndre_data_sub$average_adjacent > 1.0)
ndre_data_sub[high_error_idx, c('average_adjacent', 'stdev_adjacent')] <- NA
ndre_data_sub <- na.omit(ndre_data_sub)
# write_csv(x = ndre_data_sub, path = './data/2_cleaned/ndre_local_data/localized_ndre_data_subset.csv')

# Soil moisture data input
soilM <- data.frame(read_csv(file = './data/2_cleaned/soil_moisture.csv'))
soilM <- transform(soilM, date = as.Date(as.character(date), format = '%Y-%m-%d'),
                   field = factor(field),
                   sensor_full_name = factor(sensor_full_name))
soilM$year <- year(soilM$date)

# summary_tbl <- soilM %>%
#     group_by(year) %>%
#     summarise('Rows' = n(),
#               'DateRange' = list(range(as.Date(date, origin='1970-01-01'))))

# crop_cleaned <- read_csv(file = './data/2_cleaned/crop_data_cleaned.csv')
# weather_cleaned <- read_csv(file = './data/2_cleaned/weather_data_cleaned.csv')

# field coordinates
coords <- read.csv('./data/1_raw/coordinates/SCF_TierII_site_coords.csv')


# files <- list.files('./data/1_raw/trimmed_ndre/', full.names = T)
# plot(raster(files[1]))
# #plot rasters
# for(i in 1:length(files)){
#     filename <- str_extract(files[i], '[^\\/][^\\/]*$')
#     field <- str_extract(filename, '^(.*?)(?=_)')
#     field = toupper(field)
#     r <- raster(files[i])
#     plot(r)
#     idx <- grep(coords$ID, pattern = field)
#     points(coords[idx,c('east','north')], pch=19)
# 
# }

# breaks <- seq(0, 1, by=0.01)
# cols <- colorRampPalette(c("red", "yellow", "lightgreen"))(length(breaks)-1)
# for(i in 1:length(files)){
#     # print(i)
#     r <- raster(files[i])
#     ## Use `at` and `col.regions` arguments to set the color scheme
#     filename <- str_extract(files[i], '[^\\/][^\\/]*$')
#     name <- str_extract(files[i], '[^\\/]+$')
#     
#     levelplot(r, at=breaks, col.regions=cols, margin=F)
#     # extract the file name after the last / in the path
#     # pic.name = paste0(name,'_scaledColor.tiff')
#     # open a graphics device for saving
#     # tiff(paste0('./images/',pic.name))
#     # print to that graphics device
#     # print(raster.list[[i]])
#     # close the graphics device
#     # dev.off()
# }

# soil physical properties input and cleaning
soil_prop <- read_csv('./data/2_cleaned/soil_properties_cleaned.csv')
soil_prop <- transform(soil_prop, field = factor(field))
soil_prop_ssc <- soil_prop[,c(1:18)]
soil_prop_ssc <- soil_prop_ssc[,-c(7,8,12,13,17,18)]
soil_prop_ssc <- na.omit(soil_prop_ssc)
soil_prop_ssc_long <- rbind(soil_prop_ssc,soil_prop_ssc, soil_prop_ssc, soil_prop_ssc, 
                            soil_prop_ssc, soil_prop_ssc)
soil_prop_ssc_long$year <- c(rep(2011, 48), rep(2012, 48), rep(2013, 48), rep(2014, 48), 
                             rep(2015, 48), rep(2016, 48))
soil_prop_ssc_long <- soil_prop_ssc_long[,-1]

# ####
# # soil moisture
# ####
# 
# soilM <- read.csv('./data/2_cleaned/soil_moisture.csv')
# soilM <- transform(soilM, date = as.Date(as.character(date), format = '%Y-%m-%d'))
# soilM$sensor_full_name <- gsub(pattern = " ", replacement = "", x = soilM$sensor_full_name)
# 
# # imputing the missing soilM data
# soilM_imputed <- soilM
# soilM_imputed[,c(5:9)] <- apply(soilM_imputed[,c(5:9)], 2, function(x) ifelse(x==0, NA, x))
# 
# plotNA.distribution(soilM_imputed$depth_1)
# plotNA.gapsize(soilM_imputed$depth_1)
# 
# # subset by field and sensor
# subset_by_sensor <- function(data){
#     sensor_list <- list()
#     sensor_name <- as.character(unique(data$sensor_full_name))
#     for(i in 1:length(sensor_name)){
#         print(i)
#         print(sensor_name[i])
#         sensor_list[[i]] <- subset(data, sensor_full_name == sensor_name[i])
#         print(apply(sensor_list[[i]][,c(5:7)], 2, function(x) sum(is.na(x))/nrow(sensor_list[[i]])))
#         print(paste0('nrows: ', nrow(sensor_list[[i]])))
#     }
#     return(sensor_list)
# }


#### create lagged dataframes of soilM
merge_df <- data.frame('orig_date' = ndre_soilM_weather_ssc_join$date,
                       'field' = ndre_soilM_weather_ssc_join$field,
                       'sensor' = ndre_soilM_weather_ssc_join$sensor)
date_vec <- ndre_soilM_weather_ssc_crop_join$date

lagged_soilM_df <- function(soilMdata, merge_df, lag=c(3,5,7)){
    tmp_list <- list()
    for(i in 1:length(lag)){
        lag_date <- merge_df$orig_date-lag[i]
        merge_df$date <- lag_date
        tmp_df <- data.frame('date' = lag_date)
        tmp_list[[i]] <- left_join(merge_df, soilMdata[,c(1,2,4:7)], 
                                   by=c('date','field','sensor'))
        names(tmp_list[[i]])[c(1,5:7)] <- c('date',
                                            paste0('l',lag[i],'_',names(tmp_list[[i]][5])),
                                            paste0('l',lag[i],'_',names(tmp_list[[i]][6])),
                                            paste0('l',lag[i],'_',names(tmp_list[[i]][7])))
        tmp_list[[i]] <- tmp_list[[i]][,-4]
    }
    combined_df <- cbind(tmp_list[[1]], tmp_list[[2]], tmp_list[[3]])
    combined_df <- combined_df[,-c(7:9,13:15)]
    return(combined_df)
}


####
# weather
####

weather <- read_csv('./data/2_cleaned/weather_data_cleaned.csv')
names(weather)[2] <- 'field'
weather <- transform(weather, date = as.Date(as.character(date), format = '%Y-%m-%d'),
                     field = factor(field))
####
# crop stuff
####
crop <- read_csv('./data/2_cleaned/crop_data_cleaned.csv')
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

lagged_df <- lagged_soilM_df(soilM, merge_df = merge_df)
A <- ndre_soilM_weather_ssc_join
B <- lagged_df

ndre_final_merge_with_lag <- cbind(A, B)
ndre_final_merge_with_lag <- ndre_final_merge_with_lag[,-c(27:29)]


# ndre_soilM_weather_join_sub <- subset(ndre_final_merge_with_lag, average_adjacent >= 0.4)


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

joined_data_no_bare_soil <- subset(joined_data_sub, average_adjacent >= 0.40)

# find duplicates

# write_csv(x = joined_data_sub, path = './data/3_merged_data_for_models/final_join_subbed_missing_soilM_with_lag.csv')
write_csv(x = joined_data_no_bare_soil, path = './data/3_merged_data_for_models/final_join_subbed_bare_soil_with_lag_40_2.csv')



