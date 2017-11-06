# setwd("~/MS_Data_Science/Capstone/data")
setwd("/Volumes/Toshiba External USB HDD Media")

library(rasterVis)
library(ggplot2)
library(stringr)

# list all the *.asc files in the directories working directory
# recursive set to true will list all files in any sub directory
# in R everything begins in your working directory unless stated otherwise
# set your working directory from the file menu Session --> Set Working Directory
files <- list.files(recursive = T, pattern = '*\\.asc$')

# set parameters
raster.list <- list()
begin = 1
end = length(files)

# need to scale from (0,1) otherwise the white spaces in the image screw everything up
breaks <- seq(0, 1, by=0.01)
cols <- colorRampPalette(c("red", "yellow", "lightgreen"))(length(breaks)-1)
for(i in begin:end){
  print(i)
  r <- raster(files[i])
  ## Use `at` and `col.regions` arguments to set the color scheme
  raster.list[[i]] <- levelplot(r, at=breaks, col.regions=cols, main = name, margin=F)
  # extract the file name after the last / in the path
  name <- str_extract(files[i], '[^\\/]+$')
  pic.name = paste0(name,'_scaledColor.tiff')
  # open a graphics device for saving
  tiff(paste0('./images/',pic.name))
  # print to that graphics device
  print(raster.list[[i]])
  # close the graphics device
  dev.off()
}

# alternate color scheme
# for(i in begin:end){
#   print(i)
#   r <- raster(files[i])
#   zeroCol <-"#B3B3B3" # gray color
#   reds <- rev(brewer.pal('YlOrRd', n = 7))
#   blues <- brewer.pal('Blues', n = 7)
#   myTheme <- rasterTheme(region = c(reds, zeroCol, blues))
#   raster.list[[i]] <- levelplot(r, at=breaks, par.settings = myTheme, margin = T, main = name)
# }
