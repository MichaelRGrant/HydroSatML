# This script rasterizes a NDRE data file into a usuable grid format


library(stringr)
library(stringi)
library(raster)
library(plyr)


# path may need to be updated
coords <- read.csv("./HydroSatML/data/soil_moisture/SCF_TierII_site_coords.csv")

raster_files <- list.files(path = "./HydroSatML/data/trimmed_ndre", full.names = T)
raster_files <- raster_files[grep(raster_files, pattern = "_no_clouds")]

# plot all the raster files
for (i in 1:length(raster_files)){
    print(i)
    plot(raster(raster_files[i]))
}

length(raster_files)
results_list <- list()
for (i in 1:10){
    print(i)
    #get raster
    raster <- raster(raster_files[i])
    # extract field name from filename
    filename <- str_extract(raster_files[i], "[^\\/][^\\/]*$")
    field_name <- toupper(str_extract(filename, "^[^_]*"))
    # extract date from filename
    raw_date <- str_extract(filename, pattern = "(?<=_ndre\\.)(.*?)(?=_no|\\.asc)")
    raw_date_split <- strsplit(raw_date, split = ".", fixed = T)
    date <- raw_date_split[[1]][1]
    year <- raw_date_split[[1]][2]
    if (nchar(date) == 2){
        split_date <- strsplit(date, "")[[1]]
        final_date <- paste(split_date[1], split_date[2], year, sep = "-")
    }
    if (nchar(date) == 3){
        date <- stri_pad_left(date, 4, 0)
        date <- strsplit(date, "")[[1]]
        split_date <- paste0(date[c(T, F)], date[c(F, T)])
        final_date <- paste(split_date[1], split_date[2], year, sep = "-")
    }
    final_date <- as.Date(final_date, format = "%m-%d-%Y")

    tryCatch({
        ## this tryCatch will pass if there is an error in the raster file
        ## and data cannot be extracted
        results_list[[i]] <- extract_exact(raster, coords, field = field_name)
        results_list[[i]]$date <- final_date
    }, error = function(e) {
        print(e)
        print(paste0("Error on number: ", i))
    }
    )
}
final_results <- ldply(results_list, data.frame)

final_results <- transform(final_results,
                           average_adjacent = as.numeric(average_adjacent),
                           stdev_adjacent = as.numeric(stdev_adjacent))

final_results <- transform(final_results, data = as.Date(date, format = "%Y-%m-%d"))

write_csv(final_results, path = "./HydroSatML/data/ndre_local_data/exact_ndre_data.csv")
