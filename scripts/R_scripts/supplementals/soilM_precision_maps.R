library(rgdal)
library(rasterVis)
library(RColorBrewer)
library(scales)
library(viridis)
library(ggthemes)
library(gridExtra)
library(grid)

# load data for soil moisture map plotting
data_for_predict <- read_csv(file = './HydroSatML/data/data_for_XGB-prediction.csv')
predictions <- read_csv(file = './HydroSatML/data/predictions.csv')[, -1]
names(predictions) <- 'soilM'
data_for_predict$soilM <- as.vector(predictions$predictions)
raster_soilM_plots <- data_for_predict[, c(1:3, 5, 14)]
raster_soilM_plots <- transform(raster_soilM_plots, cutoff_soilM = ifelse(ndre_val < 0.45, NA, soilM))

# subset each field for seperate plotting
W_r <- subset(raster_soilM_plots, field == 'W')
J_r <- subset(raster_soilM_plots, field == 'J')
OD_r <- subset(raster_soilM_plots, field == 'OD')
AES_r <- subset(raster_soilM_plots, field == 'AES')

# set the color palette to blues
colr <- colorRampPalette(brewer.pal(9, 'Blues'))

# create a raster file from each data frame
W_rr <- rasterFromXYZ(W_r[,c(1,2,6)])
AES_rr <- rasterFromXYZ(AES_r[,c(1,2,6)])
OD_rr <- rasterFromXYZ(OD_r[,c(1,2,6)])
J_rr <- rasterFromXYZ(J_r[,c(1,2,6)])
raster_list <- c(W_rr, AES_rr, OD_rr, J_rr)
field_name <- c('W', 'AES', 'OD', 'J')

## Make the soil moisture maps from predicted soil moisture
Wgg <- ggplot() +
    geom_raster(data=W_r, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.95, interpolate = T) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85, limits=c(0.14,0.25)) +
    coord_fixed() +
    theme_map()+
    theme(legend.position="bottom",
          legend.key.width=unit(2, "cm"),
          title = element_text(size = 25),
          plot.title = element_text(hjust=0.5),
          legend.text = element_text(size=20)) +
    labs(fill='Soil Moisture') +
    ggtitle('Field W - 06/30/2014')

AESgg <- ggplot() +
    geom_raster(data=AES_r, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.95, interpolate = T) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85, limits=c(0.14,0.25)) +
    coord_equal()+
    theme_map()+
    theme(legend.position="bottom",
          legend.key.width=unit(2, "cm"),
          title = element_text(size = 25),
          plot.title = element_text(hjust=0.5),
          legend.text = element_text(size=20)) +
    labs(fill='Soil Moisture') +
    ggtitle('Field AES - 06/07/2012')

ODgg <- ggplot() +
    geom_raster(data=OD_r, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.95, interpolate = T) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85, limits=c(0.14,0.25)) +    
    coord_equal() +
    theme_map()+
    theme(legend.position="bottom",
          legend.key.width=unit(2, "cm"),
          title = element_text(size = 25),
          plot.title = element_text(hjust=0.5),
          legend.text = element_text(size=20)) +
    labs(fill='Soil Moisture') +
    ggtitle('Field OD - 05/25/2012')

Jgg <- ggplot() +
    geom_raster(data=J_r, aes(x = x, y=y, fill=cutoff_soilM), alpha=0.95, interpolate = T) +
    scale_fill_viridis(direction = -1, begin = 0.05, end=0.85, limits=c(0.14,0.25)) +
    coord_equal() +
    theme_map()+
    theme(legend.position="bottom",
          legend.key.width=unit(2, "cm"), 
          title = element_text(size = 25),
          plot.title = element_text(hjust=0.5),
          legend.text = element_text(size=20))+
    labs(fill='Soil Moisture') +
    ggtitle("Field J - 06/29/2013")

ggarrange(Jgg, AESgg, Wgg, ODgg, ncol=2, nrow=2, common.legend = T, legend = 'bottom')
