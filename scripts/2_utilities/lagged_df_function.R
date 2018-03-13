# Function for merging NDRE and soil moisture sets with a date lag
# Done in consideration of potential relationship with watershed accumulation.

lagged_soilM_df <- function(soilMdata, merge_df, lag=c(3, 5, 7)){
    tmp_list <- list()
    for (i in 1:length(lag)){
        lag_date <- merge_df$orig_date - lag[i]
        merge_df$date <- lag_date
        tmp_df <- data.frame("date" = lag_date)
        tmp_list[[i]] <- left_join(merge_df, soilMdata[, c(1, 2, 4:7)],
                                   by = c("date", "field", "sensor"))
        names(tmp_list[[i]])[c(1, 5:7)] <- c("date",
                                            paste0("l", lag[i], "_", names(tmp_list[[i]][5])),
                                            paste0("l", lag[i], "_", names(tmp_list[[i]][6])),
                                            paste0("l", lag[i], "_", names(tmp_list[[i]][7])))
        tmp_list[[i]] <- tmp_list[[i]][, -4]
    }
    combined_df <- cbind(tmp_list[[1]], tmp_list[[2]], tmp_list[[3]])
    combined_df <- combined_df[, -c(7:9, 13:15)]
    return(combined_df)
}