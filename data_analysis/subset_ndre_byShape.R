library(rgdal)
library(ggplot2)
library(stringr)

# load the data
setwd("/Volumes/Toshiba External USB HDD Media")
ndrefiles <- list.files(recursive = T, pattern = '*\\.asc$', full.names = T)
ndrefiles <- normalizePath(ndrefiles)

setwd("~/MS_Data_Science/Capstone/HydroSatML")
shpfiles <- list.files(path = './data/TierII_wshed_boundaries/',
                       recursive = T, pattern = '*\\.shp$', full.names = T)
shpfiles <- normalizePath(shpfiles)

error_log <- c()
e.num <- 1
for(i in 1:length(ndrefiles)){
    print(i)
    name <- str_extract(ndrefiles[i], '[^\\/]+$')
    filename <- str_extract(ndrefiles[i], '[^\\/][^\\/]*$')
    location <- str_extract(filename, '^[^_]*')
    if(location == 'Aes'){
        shpfile <- str_extract(shpfiles[1], '[^\\/][^\\/]*$')
        shpfile <- str_extract(shpfile, '.*(?=\\.)')
        shpfile_path <- str_extract(shpfiles[1], '^(.*[\\/])')
        shape <- readOGR(shpfile_path, shpfile)
    }
    else if(location == 'J'){
        
        shpfile <- str_extract(shpfiles[2], '[^\\/][^\\/]*$')
        shpfile <- str_extract(shpfile, '.*(?=\\.)')
        shpfile_path <- str_extract(shpfiles[2], '^(.*[\\/])')
        shape <- readOGR(shpfile_path, shpfile)
    }
    else if(location == 'Od'){
        
        shpfile <- str_extract(shpfiles[3], '[^\\/][^\\/]*$')
        shpfile <- str_extract(shpfile, '.*(?=\\.)')
        shpfile_path <- str_extract(shpfiles[3], '^(.*[\\/])')
        shape <- readOGR(shpfile_path, shpfile)
    }
    else if(location == 'W'){
        shpfile <- str_extract(shpfiles[4], '[^\\/][^\\/]*$')
        shpfile <- str_extract(shpfile, '.*(?=\\.)')
        shpfile_path <- str_extract(shpfiles[4], '^(.*[\\/])')
        shape <- readOGR(shpfile_path, shpfile)
    }
    tryCatch({
        r <- raster(x = ndrefiles[i])
        masked <- mask(r, shape)
    }, error = function(e) {
        print(e)
        print(paste0('Error on number: ', i))
    })
    tryCatch({
        trimmed <- trim(masked)
        plot(trimmed)
        path <- "/Users/mgrant/MS_Data_Science/Capstone/data/trimmed_ndre/"
        finalname <- paste0(path, name)
        print(finalname)
        writeRaster(trimmed, filename = finalname, format = 'ascii', overwrite=T)
    }, error = function(e) {
        print(e)
        print(paste0('Number ', i, ' error.'))
        # error_log[e.num] <- 'testing'
        # e.num = e.num + 1
    } )
    
   
}

