extract_date <- function(raw_date){
    require(stringi)
    require(stringr)
    raw_date <- str_extract(raw_date, pattern = '(?<=_ndre\\.)(.*?)(?=_no|\\.asc)')
    raw_date_split <- strsplit(raw_date, split = '.', fixed = T)
    date <- raw_date_split[[1]][1]
    year <- raw_date_split[[1]][2]
    if(nchar(date)==2){
        split_date <- strsplit(date,"")[[1]]
        final_date <- paste(split_date[1], split_date[2], year, sep = '-')
    }
    if(nchar(date)==3){
        date <- stri_pad_left(date, 4, 0)
        date <- strsplit(date,"")[[1]]
        split_date <- paste0(date[c(T,F)], date[c(F,T)])
        final_date <- paste(split_date[1], split_date[2], year, sep = '-')
    }
    final_date <- as.Date(final_date, format = '%m-%d-%Y')
    return(final_date)
}