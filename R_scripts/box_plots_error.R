setwd("~/MS_Data_Science/Capstone/HydroSatML/")

library(ggplot2)
library(readr)
library(dplyr)

NN <- data.frame(read_csv(file = './data/results_data/results_df_NN.csv')[,-1])
RR <- data.frame(read_csv(file = './data/results_data/results_df_lin_RR.csv')[,-1])
XG <- data.frame(read_csv(file = './data/results_data/xg_mae_df_results.csv')[,-1])
SMR <- data.frame(read_csv(file = './data/results_data/merge_sm_error_results.csv'))

summary_tbl <- data.frame(SMR %>%
    group_by(date) %>%
    summarise('MAE' = mean(error, na.rm=T)))


SMR_error <- data.frame('MAE' = summary_tbl$MAE)

NN$model <- 'Neural Network'
names(NN)[1] <- 'MAE'
RR$model <- 'Ridge Regression'
names(RR)[1] <- 'MAE'
XG$model <- 'XGBoost'
names(XG)[1] <- 'MAE'
SMR_error$model <- 'SMR'
tidy_error <- rbind(NN, RR, XG, SMR_error)

tidy_error$MAE <- sapply(tidy_error$MAE, function(x) ifelse(x=='NaN', NA, x))
tidy_error <- na.omit(tidy_error)

boxplot <- ggplot(tidy_error, aes(x=model, y=MAE)) +
    geom_boxplot(aes(fill = model)) +
    xlab('') +
    ylab('Mean Absolute Error') +
    ggtitle('Comparing Error Between Models') +
    labs(fill='Model') +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 25),
          axis.text.y = element_text(size = 25,
                                     margin = margin(0,0,0,15)),
          axis.title.x = element_text(size = 35,
                                      margin = margin(0,0,0,10)),
          title = element_text(size = 45),
          legend.position = 'none')
boxplot
