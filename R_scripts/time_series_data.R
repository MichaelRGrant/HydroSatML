library(readr)
library(dplyr)
library(lubridate)
library(raster)
library(rasterVis)
library(stringr)
library(imputeTS)
setwd("~/MS_Data_Science/Capstone")



soilM <- data.frame(read_csv(file = './HydroSatML/data/soil_moisture/output_data/soil_moisture.csv'))
soilM <- transform(soilM, date = as.Date(as.character(date), format = '%m/%d/%y'),
                   field = factor(field),
                   sensor_full_name = factor(sensor_full_name))
soilM[,5:7] <- apply(soilM[,5:7], 2, function(x) ifelse(x=='NaN', NA, x))
soilM$avg_soilM <- rowMeans(soilM[,5:7], na.rm = T)
soilM <- soilM[,-c(3, 5:9)] 
soilM_spread <- spread(soilM, key='sensor', value='avg_soilM')

soilM_spread[,c(3:14)] <- apply(soilM_spread[,c(3:14)], 2, function(x) ifelse(x=='NaN', NA, x))

soilM_spread$soilM_avg <- rowMeans(soilM_spread[,3:14], na.rm=T)
soilM_spread <- soilM_spread[,-c(3:14)]
AES <- soilM_spread[soilM_spread[,2]=='AES',]
OD <- soilM_spread[soilM_spread[,2]=='OD',]
W <- soilM_spread[soilM_spread[,2]=='W',]
J <- soilM_spread[soilM_spread[,2]=='J',]

for(i in 3:length(AES)){
    print(i)
    if(i == 10 | i==11){}
    else{plotNA.distribution(AES[,i], main = paste0('AES',i-2))}
}
for(i in 3:length(W)){
    print(i)
    plotNA.distribution(W[,i], main = paste0('W',i-2))
}
for(i in 3:length(J)){
    print(i)
    plotNA.distribution(J[,i], main = paste0('J',i-2))
}
for(i in 3:length(OD)){
    print(i)
    plotNA.distribution(OD[,i], main = paste0('OD',i))
}

# soilM$year <- year(soilM$date)

weather <- read_csv('./HydroSatML/data/weather/weather_data_cleaned.csv')
names(weather)[2] <- 'field'
weather <- transform(weather, date = as.Date(as.character(date), format = '%Y-%m-%d'),
                     field = factor(field))

soil_prop <- read_csv('./HydroSatML/data/site_analysis/soil_properties/soil_properties_cleaned.csv')
soil_prop <- transform(soil_prop, field = factor(field))
soil_prop_ssc <- soil_prop[,c(1:18)]
soil_prop_ssc <- soil_prop_ssc[,-c(7,8,12,13,17,18)]
soil_prop_ssc <- na.omit(soil_prop_ssc)
soil_prop_ssc <- soil_prop_ssc[-1]

soil_prop_ssc$avg_sand <- rowMeans(soil_prop_ssc[,3:5])
soil_prop_ssc$avg_silt <- rowMeans(soil_prop_ssc[,6:8])
soil_prop_ssc$avg_clay <- rowMeans(soil_prop_ssc[,9:11])
soil_prop_ssc <- soil_prop_ssc[,-c(3:11)]

sand <- soil_prop_ssc[,c(1,2,3)]
silt <- soil_prop_ssc[,c(1,2,4)]
clay <- soil_prop_ssc[,c(1,2,5)]


# field_spread <- function(data){
#     fields_list <- list()
#     fields <- unique(data$field)
#     for(i in 1:length(fields)){
#         print(as.character(fields[i]))
#         fields_list[[i]] <- subset(data, field == fields[i])
#         field <- unique(fields_list[[i]]$field)
#         spread_dat <- spread(data, key='sensor', value=names(data)[3])
#         spread_dat$field <- field
#     }
#     fin_dat <- ldply(fields_list, data.frame)
#     return(fin_dat)
# }
# test <- field_spread(sand)


# test <- sand %>%
#     unite('groups', field, sensor) %>%
#     spread(groups, avg_sand)
sand <- spread(sand, key = 'sensor', value = names(sand)[3])
silt <- spread(silt, key = 'sensor', value = names(silt)[3])
clay <- spread(clay, key = 'sensor', value = names(clay)[3])
sand$average_sand <- rowMeans(sand[,2:13], na.rm = T)
silt$average_silt <- rowMeans(silt[,2:13], na.rm = T)
clay$average_clay <- rowMeans(clay[,2:13], na.rm = T)
sand <- sand[,-c(2:13)]
silt <- silt[,-c(2:13)]
clay <- clay[,-c(2:13)]
soil_prop <- merge(sand, silt, by='field')
soil_prop <- merge(soil_prop, clay, by='field')
# soil_prop <- left_join(sand, silt, by=c('field','sensor'))
# soil_prop <- left_join(soil_prop, clay, by = c('field', 'sensor'))
# test <- spread(soil_prop_ssc, key = 'sensor', value = 'avg_sand')
# test <- dcast(setDT(soil_prop_ssc), sensor ~ avg_, value.var=c('avg_sand', 'avg_silt', 'avg_clay'))

# soil_prop_ssc_long <- rbind(soil_prop_ssc,soil_prop_ssc, soil_prop_ssc, soil_prop_ssc, 
#                             soil_prop_ssc, soil_prop_ssc)
# soil_prop_ssc_long$year <- c(rep(2011, 48), rep(2012, 48), rep(2013, 48), rep(2014, 48), 
#                              rep(2015, 48), rep(2016, 48))
# soil_prop_ssc_long <- soil_prop_ssc_long[,-1]


first_join <- left_join(soilM_spread, weather,  by=c('field', 'date'))
second_join <- left_join(first_join, soil_prop,  by=c('field'))

time_series_data <- second_join
time_series_data$avg_soilM <- rowMeans(x = time_series_data[,5:7], na.rm = TRUE)
time_series_data$avg_clay <- rowMeans(time_series_data[,c(21:23)], na.rm = T)
time_series_data$avg_sand <- rowMeans(time_series_data[,c(15:17)], na.rm = T)
time_series_data$avg_silt <- rowMeans(time_series_data[,c(18:20)], na.rm = T)
time_series_data <- time_series_data[,-c(3,5:9,15:23)]

add_full_time <- function(data){
    require(plyr)
    fields_list <- list()
    fields <- unique(data$field)
    for(i in 1:length(fields)){
        print(as.character(fields[i]))
        fields_list[[i]] <- subset(data, field == fields[i])
        field <- unique(fields_list[[i]]$field)
        date_range <- range(fields_list[[i]]$date, na.rm=T)
        date_seq <- seq(date_range[1], date_range[2], by ='1 day')
        date_seq <- data.frame('date' = as.Date(date_seq, format = '%Y-%m-%d'))
        fields_list[[i]] <- right_join(fields_list[[i]], date_seq, by='date')
        fields_list[[i]]$field <- field
    }
    final <- ldply(fields_list, data.frame)
    return(final)
}

second_join$soilM_avg <- sapply(second_join$soilM_avg, function(x) ifelse(x=='NaN', NA, x))

write_csv(second_join, path = './HydroSatML/data/time_series_soilM_averaged.csv')

## make the data long
library(tidyr)
test <- spread(time_series_data, key='sensor', value='avg_soilM')
