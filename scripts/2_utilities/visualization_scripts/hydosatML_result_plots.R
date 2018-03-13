library(ggplot2)
library(tidyr)

setwd("~/MS_Data_Science/Capstone/")

xg_data <- read.csv('./jupyter notebooks/results_df_xgboost.csv')[-1]
lin_data <- read.csv('./HydroSatML/data/results_data/results_df_lin.csv')[-1]

fin_data <- cbind(xg_data, lin_data)

xg_data_mae <- xg_data[,c(1,4,7,10)]

xg_data_mae_long <- gather(data = xg_data_mae, key='Legend', value='value')
xg_data_mae_long <- transform(xg_data_mae_long, 
                              'Legend' = factor(Legend, 
                                             levels = c('soilM_mae', 'soilM_l3_mae', 'soilM_l5_mae', 'soilM_l7_mae'),
                                             labels = c('Real Time', 'Lag 3 Days', 'Lag 5 Days', 'Lag 7 Days')))


names(fin_data)
compare_data <- fin_data[,c('rr_mae_l3', 'svrg_mae_l3', 'soilM_l3_mae')]
compare_data_long <- gather(data = compare_data, key='Legend', value='value')
compare_data_long <- transform(compare_data_long, 
                               'Legend' = factor(Legend,
                                                 levels = c('rr_mae_l3', 'svrg_mae_l3', 'soilM_l3_mae'),
                                                 labels = c('Ridge Regression', 'Gaussian SVR', 'XGBoost')))


box_xg <- ggplot(xg_data_mae_long, aes(Legend, value)) +
    stat_boxplot(geom='errorbar', width=0.3) +
    geom_boxplot(aes(fill=Legend), outlier.size = 1) +
    theme_bw() +
    theme(axis.text.x = element_text(size = 15),
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(size = 15, colour = 'black',
                                     margin = margin(0,0,0,10)),
          axis.title.y = element_text(size = 20,
                                      margin = margin(0,0,0,15)),
          title=element_text(size=25),
          panel.border = element_rect(size = 1, colour = 'black'),
          panel.background = element_blank(),
          panel.grid = element_blank(),
          legend.position = 'none') +
    xlab('') +
    ylab('MAE') +
    ggtitle('XGBoost Comparison Between Different Lag Times')
box_xg

box_models <- ggplot(compare_data_long, aes(Legend, value)) +
    stat_boxplot(geom='errorbar', width=0.3) +
    geom_boxplot(aes(fill=Legend), outlier.size = 1) +
    theme_bw() +
    theme(axis.text.x = element_text(size = 15),
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(size = 15, colour = 'black',
                                     margin = margin(0,0,0,10)),
          axis.title.y = element_text(size = 20,
                                      margin = margin(0,0,0,15)),
          title=element_text(size=25),
          panel.border = element_rect(size = 1, colour = 'black'),
          panel.background = element_blank(),
          panel.grid = element_blank(),
          legend.position = 'none') +
    xlab('') +
    ylab('MAE') +
    ggtitle('Comparing Models all with 3 Day Lag')
box_models
