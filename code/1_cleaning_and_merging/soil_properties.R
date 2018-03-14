##################
#### Function ####
##################

extractSoilProperties <- function(path, sheet, range, sand, silt, clay) {
  
  # import and duplicate
  df <- readxl::read_excel(path=path, sheet=sheet, range=range)
  df2 <- df
  
  # combine duplicates for each year of data
  df$year <- 2011
  df2$year <- 2012
  df <- rbind(df, df2)
  
  # set data to NA for years without readings
  df[df$year==2012, sand] <- NA
  df[df$year==2012, silt] <- NA
  df[df$year==2012, clay] <- NA
  
  # consolidate yearly columns
  df$TN <- ifelse(df$year==2011, df$`TN-2011`, df$`TN-2012`)
  df$TC <- ifelse(df$year==2011, df$`TC-2011`, df$`TC-2012`)
  df$`TN-2011` <- NULL
  df$`TN-2012` <- NULL
  df$`TC-2011` <- NULL
  df$`TC-2012` <- NULL
  
  # create placeholder for new data
  df_new <- data.frame(date=df$year)
  df_new$field <- df$Farm
  df_new$sensor <- df$Site
  df_new <- unique(df_new)
  
  # create new columns
  colsToSpread <- c(sand, silt, clay, "TN", "TC")
  
  # split data to new columns
  for (col in colsToSpread) {
    
    # assign new column names as necessary
    if (col=="Sand (%)") {
      colPrefix <- "sand"
    } else if (col=="Silt (%)") {
      colPrefix <- "silt"
    } else if (col=="Clay (%)") {
      colPrefix <- "clay"
    } else {
      colPrefix <- col
    }
      
    # fill new columns
    for (d in sort(unique(df$`Depth (ft.)`))) {
      newCol <- paste0(colPrefix, "_", d)
      df_new[,newCol] <- df[df$`Depth (ft.)`==d, col]
    }
  }
  
  # return new dataframe
  return(df_new)
  
}

###############
#### Setup ####
###############

library(readxl)
library(tidyr)
setwd("~/Desktop/HydroSatML/data/1_raw/site_analysis/")

#############
#### AES ####
#############

# set properties for data import
path <- "Aes_site_analysis_FINAL.xlsx"
sheet <- "SOIL PROPERTIES"
range <- "I5:R65"
sand <- "Sand (%)"
silt <- "Silt (%)"
clay <- "Clay (%)"

aes <- extractSoilProperties(path=path, sheet=sheet, range=range, sand=sand, silt=silt, clay=clay)
# View(aes)

###########
#### J ####
###########

# set properties for data import
path <- "J_site_analysis_FINAL.xlsx"
sheet <- "SOIL_PROPERTIES"
range <- "A5:O65"
sand <- "sand"
silt <- "silt"
clay <- "clay"

j <- extractSoilProperties(path=path, sheet=sheet, range=range, sand=sand, silt=silt, clay=clay)
# View(j)


############
#### OD ####
############

# set properties for data import
path <- "Od_site_analysis_FINAL.xlsx"
sheet <- "SOIL_PROPERTIES"
range <- "E4:V64"
sand <- "sand"
silt <- "silt"
clay <- "clay"

od <- extractSoilProperties(path=path, sheet=sheet, range=range, sand=sand, silt=silt, clay=clay)
# View(od)


############
#### W ####
############

# set properties for data import
path <- "W_site_analysis_FINAL.xlsx"
sheet <- "SOIL PROPERTIES"
range <- "G4:U64"
sand <- "sand"
silt <- "silt"
clay <- "clay"

w <- extractSoilProperties(path=path, sheet=sheet, range=range, sand=sand, silt=silt, clay=clay)
# View(w)


###############
#### Merge ####
###############

# row bind
df_new <- rbind(aes, j, od, w)

# rename fields
df_new$field[df_new$field=="JNS"] <- "J"
df_new$field[df_new$field=="ODB"] <- "OD"
df_new$field[df_new$field=="WLF"] <- "W"

# export cleaned data as csv
readr::write_csv(df_new, "../../2_cleaned/soil_properties_cleaned.csv", na="")
