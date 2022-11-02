date_test <- seq(ymd_hms('2016-07-01 00:30:00'),ymd_hms('2016-07-01 01:30:00'), by = '15 min')
date_test <- data.frame(datetime=date_test)
date_test

d<-as.POSIXct(paste0("2016-07-01"," ", "01:00:00"), tz="UTC")


date_test %>% 
  filter(datetime > d)


# my data
d<-as.POSIXct(paste0("2022-08-03"," ", "07:45:00"), tz="UTC")
e<-as.POSIXct(paste0("2022-08-03"," ", "07:55:00"), tz="UTC")


dfsub <- df %>% mutate(timestamp = as.POSIXct(timestamp, tz="UTC")) %>%
  filter(timestamp >= d & timestamp <=e)