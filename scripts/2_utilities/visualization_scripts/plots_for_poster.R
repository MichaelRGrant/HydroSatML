# NDRE Spatial Plots for Capstone Poster

# Import Libraries
library(raster)
library(rgdal)

# Set Working Directory
setwd("~/Desktop/HydroSatML")

#### Data Import

# OD satellite swath raster
od <- raster("~/Downloads/Od_ndre.630.2016.asc")

# OD farm shape
shpfile_path <- "./data/TierII_wshed_boundaries/Od_wshed/"
shpfile <- "wshed_odberg"
shape <- readOGR(shpfile_path, shpfile)

#### MASKS

# bare soil cutoff
od[od < 0.48] <- NA

# NW corner cutout
od[cellFromRowColCombine(od, 1:120, 1:40)] <- NA
od[cellFromRowColCombine(od, 1:90, 1:100)] <- NA
od[cellFromRowColCombine(od, 1:55, 1:160)] <- NA

# SE corner cutout
od[cellFromRowColCombine(od, 300:348, 170:284)] <- NA
od[cellFromRowColCombine(od, 250:348, 200:284)] <- NA
od[cellFromRowColCombine(od, 200:348, 240:284)] <- NA

plot(od, colNA = "gray50")
plot(shape, lwd = 4, border = "red", add = TRUE)

#### SUBSET PLOT

# Subset shape
masked <- mask(od, shape)
# plot(masked)
trimmed <- trim(masked)
plot(trimmed, colNA = "gray50")
