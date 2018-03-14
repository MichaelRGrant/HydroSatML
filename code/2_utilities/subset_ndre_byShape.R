# This script will subset the field farm shapes out of the NDRE satellite image maps


library(rgdal)
library(ggplot2)
library(stringr)

# Loading the data from external drive path
setwd("/Volumes/Toshiba External USB HDD Media")

# list.files will scan a directory and add all the files to a list
ndrefiles <- list.files(recursive = T, pattern = "*\\.asc$", full.names = T)

# add absolute paths to the files in that list
ndrefiles <- normalizePath(ndrefiles)

setwd("~/MS_Data_Science/Capstone/HydroSatML")
shpfiles <- list.files(path = "./data/TierII_wshed_boundaries/",
                       recursive = T, pattern = "*\\.shp$", full.names = T)
shpfiles <- normalizePath(shpfiles)

# error_log <- c()
# e.num <- 1
# loop through the file list created above
for (i in 1:length(ndrefiles)){
    print(i)
    # some regex expressions to extract the file names out of the aboslute paths
    name <- str_extract(ndrefiles[i], "[^\\/]+$")
    filename <- str_extract(ndrefiles[i], "[^\\/][^\\/]*$")
    # extract the location out of the filename to make sure the correct shapefile gets used
    location <- str_extract(filename, "^[^_]*")
    # conditionals set up to match the correct shapefile
    if (location == "Aes"){
        shpfile <- str_extract(shpfiles[1], "[^\\/][^\\/]*$")
        shpfile <- str_extract(shpfile, ".*(?=\\.)")
        shpfile_path <- str_extract(shpfiles[1], "^(.*[\\/])")
        shape <- readOGR(shpfile_path, shpfile)
    }
    else if (location == "J"){
        shpfile <- str_extract(shpfiles[2], "[^\\/][^\\/]*$")
        shpfile <- str_extract(shpfile, ".*(?=\\.)")
        shpfile_path <- str_extract(shpfiles[2], "^(.*[\\/])")
        shape <- readOGR(shpfile_path, shpfile)
    }
    else if (location == "Od"){
        shpfile <- str_extract(shpfiles[3], "[^\\/][^\\/]*$")
        shpfile <- str_extract(shpfile, ".*(?=\\.)")
        shpfile_path <- str_extract(shpfiles[3], "^(.*[\\/])")
        shape <- readOGR(shpfile_path, shpfile)
    }
    else if (location == "W"){
        shpfile <- str_extract(shpfiles[4], "[^\\/][^\\/]*$")
        shpfile <- str_extract(shpfile, ".*(?=\\.)")
        shpfile_path <- str_extract(shpfiles[4], "^(.*[\\/])")
        shape <- readOGR(shpfile_path, shpfile)
    }
    # load the raster wrapped in an error handler to skip if this file does not load
    tryCatch ({
        r <- raster(x = ndrefiles[i])
        # will turn all values outside the shapefile into NAs in the matrix
        masked <- mask(r, shape)
    }, error = function(e) {
        print(e)
        print(paste0("Error on number: ", i))
    })
    tryCatch ({
        # will remove all NAs in raster matrix
        trimmed <- trim(masked)
        plot(trimmed)
        path <- "/Users/mgrant/MS_Data_Science/Capstone/data/trimmed_ndre/"
        finalname <- paste0(path, name)
        print(finalname)
        # write the trimmed raster to file
        writeRaster(trimmed, filename = finalname, format = "ascii", overwrite = T)
    }, error = function(e) {
        print(e)
        print(paste0("Number", i, "error."))
        # error_log[e.num] <- 'testing'
        # e.num = e.num + 1
    } )
}
