# Script to plot NDRE data

# Set working directory
setwd("~/MS_Data_Science/Capstone/HydroSatML/")

# Import Libraries
library(rasterVis)
library(raster)
library(ggplot2)

#Import NDRE data and extract using raster function
files <- list.files(path = "./data/trimmed_ndre", full.names = T)

for (i in 1:32){
    r <- raster(files[i])
    plot(r, main = files[i])
}

W <- files[113]
AES <- files[27]
OD <- files[74]
J <- files[44]


fields <- c(W, AES, OD, J)
fields_name <- c("W", "AES", "OD", "J")

raster_list <- list()
## Extract the ndre values and UTM coordinates
for (i in 1:4){
    r <- raster(fields[i])
    raster_list[[i]] <- as.data.frame(rasterToPoints(r))
    # names(raster_list)[i] <- fields_name[i]
    if (i == 1){
        field <- fields_name[i]
        raster_list[[i]]$field <- field
        raster_list[[i]]$date <- as.Date("2014/06/30", format = "%Y/%m/%d")
    }
    else if (i == 2){
        field <- fields_name[i]
        raster_list[[i]]$field <- field
        raster_list[[i]]$date <- as.Date("2012/07/06", format = "%Y/%m/%d")
    }
    else if (i == 3){
        field <- fields_name[i]
        raster_list[[i]]$field <- field
        raster_list[[i]]$date <- as.Date("2012/05/25", format = "%Y/%m/%d")
    }
    else{
        field <- fields_name[i]
        raster_list[[i]]$field <- field
        raster_list[[i]]$date <- as.Date("2013/06/29", format = "%Y/%m/%d")
    }

}

ndre_for_predict <- ldply(raster_list, data.frame)
names(ndre_for_predict)[c(3, 6:8)] <- c("W", "AES", "OD", "J")
ndre_for_predict <- transform(ndre_for_predict, field = factor(field))
ndre_predict_long <- gather(data = ndre_for_predict, key = "field", value = "ndre_val", c(3, 6:8), na.rm = T)
ndre_predict_long <- ndre_predict_long[, -5]
ndre_predict_long$year <- year(ndre_predict_long$date)

# Clean data for merge
soil_prop <- read_csv("./data/site_analysis/soil_properties/soil_properties_cleaned.csv")
soil_prop <- transform(soil_prop, field = factor(field))
soil_prop_ssc <- soil_prop[, c(1:18)]
soil_prop_ssc <- soil_prop_ssc[, -c(7, 8, 12, 13, 17, 18)]
soil_prop_ssc <- na.omit(soil_prop_ssc)
soil_prop_ssc_long <- rbind(soil_prop_ssc, soil_prop_ssc, soil_prop_ssc)
soil_prop_ssc_long$year <- c(rep(2012, 48), rep(2013, 48), rep(2014, 48))
soil_prop_ssc_long <- soil_prop_ssc_long[, -1]
#average the soilprop data
soil_prop <- soil_prop_ssc_long
soil_prop$avg_sand <- rowMeans(soil_prop[, 3:5])
soil_prop$avg_silt <- rowMeans(soil_prop[, 6:8])
soil_prop$avg_clay <- rowMeans(soil_prop[, 9:11])
soil_prop <- soil_prop[, -c(3:11)]
row.names(soil_prop) <- NULL
soil_prop_summ <- data.frame(soil_prop %>%
    group_by_("field", "year") %>%
    summarise("avg_sand" = mean(avg_sand),
              "avg_silt" = mean(avg_silt),
              "avg_clay" = mean(avg_clay)))

weather <- read_csv("./data/weather/weather_data_cleaned.csv")
names(weather)[2] <- "field"
weather <- transform(weather, date = as.Date(as.character(date), format = "%Y-%m-%d"),
                     field = factor(field))
# Merge the data

merge1 <- left_join(ndre_predict_long, soil_prop_summ, by = c("field", "year"))
merge2 <- left_join(merge1, weather, by = c("date", "field"))
data_for_predict <- merge2[, -6]
# write_csv(data_for_predict, path = './data/data_for_XGB-prediction.csv')

# Adding predicted values to data frame

predictions <- read.csv(file = "./data/predictions.csv")[-1]
names(predictions) <- "soilM"

data_for_predict$soilM <- as.vector(predictions$predictions)
raster_soilM_plots <- data_for_predict[, c(1:3, 5, 14)]

raster_soilM_plots <- transform(raster_soilM_plots, cutoff_soilM = ifelse(ndre_val < 0.45, NA, soilM))



W_r <- subset(raster_soilM_plots, field == "W")
J_r <- subset(raster_soilM_plots, field == "J")
OD_r <- subset(raster_soilM_plots, field == "OD")
AES_r <- subset(raster_soilM_plots, field == "AES")

W_rr <- rasterFromXYZ(W_r[, c(1, 2, 5)])
AES_rr <- rasterFromXYZ(AES_r[, c(1, 2, 5)])
OD_rr <- rasterFromXYZ(OD_r[, c(1, 2, 5)])
J_rr <- rasterFromXYZ(J_r[, c(1, 2, 5)])

W_rr <- rasterFromXYZ(W_r[, c(1, 2, 6)])
AES_rr <- rasterFromXYZ(AES_r[, c(1, 2, 6)])
OD_rr <- rasterFromXYZ(OD_r[, c(1, 2, 6)])
J_rr <- rasterFromXYZ(J_r[, c(1, 2, 6)])

plot(W_rr)
plot(AES_rr)
plot(OD_rr)
plot(J_rr)


# cols <- colorRampPalette(c("red", "yellow", "lightgreen"))(length(breaks)-1)
breaks <- seq(0.13, 0.26, by = 0.01)
reds <- rev(brewer.pal("YlOrRd", n = 9))
blues <- brewer.pal("Blues", n = 9)
myTheme <- rasterTheme(region = c(reds, blues))
AES_fr <- levelplot(AES_rr, par.settings = myTheme, margin = T)
plot(AES_fr)

# Saving plot

tiff(paste0("./images/", pic.name))
# print to that graphics device
print(raster.list[[i]])
# close the graphics device
dev.off()
