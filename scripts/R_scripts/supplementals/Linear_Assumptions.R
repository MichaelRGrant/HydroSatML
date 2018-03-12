# Set path to the main repository folder

setwd("C:/Users/Samir Patel/desktop/Data 590 - Capstone I/HydroSatML")


# Opening merged data set

ndre_data <- read.csv("./data/final_join_subbed_bare_soil_with_lag_40_EXACT_NDRE.csv")


# Retrieving list of columns in dataset

col_list <- names(ndre_data)
col_list


# Full LM model with all variables

model_1 <- lm(avg_soilM ~ ., data = ndre_data)


# List of various bivariate linear regression models (soil moisture vs...)

lm_list <- list()
t <- 1

for (i in 1:(length(col_list) - 1)){

  Formula <- formula(paste("avg_soilM ~ ", col_list[i]))
  lm_list[[t]] <- lm(Formula, data = ndre_data)
  t <- t  + 1

}

lm_list


# Creating directory folder for output

dir.create("R Plots")

# Looping through LM models and Output Graphs Locally¶

for (i in 1:length(lm_list)){
  print(i)
  mypath <- file.path("R Plots", paste("myplot_",
                                       col_list[i], ".jpg", sep = ""))

  jpeg(file = mypath)
  mytitle <- paste("Variable", col_list[i])
  par(mfrow = c(2, 2))

  lm_list[[i]]
  plot(lm_list[[i]], main = mytitle)
  dev.off()

}
