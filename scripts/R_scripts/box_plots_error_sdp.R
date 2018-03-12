setwd("~/MS_Data_Science/Capstone/HydroSatML/")
setwd("C:/Users/Samir Patel/Desktop/Data 590 - Capstone I/HydroSatML/")


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

NN$model <- 'Neural\nNetwork'
names(NN)[1] <- 'MAE'
RR$model <- 'Ridge\nRegression'
names(RR)[1] <- 'MAE'
XG$model <- 'XGBoost'
names(XG)[1] <- 'MAE'
SMR_error$model <- 'SMR'
tidy_error <- rbind(RR, XG, NN, SMR_error)

tidy_error$model <- factor(tidy_error$model, levels = c('Ridge\nRegression',
                                                                         'XGBoost',
                                                                         'Neural\nNetwork',
                                                                         'SMR'))


tidy_error$MAE <- sapply(tidy_error$MAE, function(x) ifelse(x=='NaN', NA, x))
tidy_error <- na.omit(tidy_error)

boxplot <- ggplot(tidy_error, aes(x=model, y=MAE)) +
    coord_fixed(ratio=40) +
    geom_boxplot(aes(fill = model)) +
    xlab('') +
    ylab('Mean Absolute Error') +
    labs(fill='Model') +
    theme(axis.text=element_text(size=50),
          title = element_text(size = 50),
          axis.title.y = element_text(margin = margin(t = 40, r = 40, b = 40, l = 40)),
          legend.position = 'none')


boxplot

png("C:/Users/Samir Patel/Desktop/Data 590 - Capstone I/HydroSatML/poster/figures/Figure_3.png", 1480, 1480, pointsize = 36)

par(bty="n")

plot(boxplot)
dev.off()

