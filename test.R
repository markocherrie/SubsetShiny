date_test <- seq(ymd_hms('2016-07-01 00:30:00'),ymd_hms('2016-07-01 01:30:00'), by = '15 min')
date_test <- data.frame(datetime=date_test)
date_test

d<-as.POSIXct(paste0("2016-07-01"," ", "01:00:00"), tz="UTC")


date_test %>% 
  filter(datetime > d)


# my data
d<-as.POSIXct(paste0("2022-08-03"," ", "07:45:00"), tz="UTC")
e<-as.POSIXct(paste0("2022-08-03"," ", "07:55:00"), tz="UTC")

req(file_data())
df <- file_data()
dfsub <- df %>% mutate(timestamp = as.POSIXct(timestamp, tz="UTC")) %>%
  filter(timestamp >= d & timestamp <=e)


df<-read.csv("testdata/EP6_20_110_sen.csv")

test<-read_excel("testdata/List_A_v2.1_AU20220103.xlsx")


test2<-"EP6_20_110_sen.csv"

sub('.*\\_', '', test2)

test2<-gsub("_sen", "", test2)
test2<-gsub(".csv", "", test2)

test<-subset(test, participantID=="EP6_20_110")

# Reactive start datetime
startdatetime2<-as.POSIXct(test$startMeasurement, format="%d-%m-%Y %H:%M", tz="CET")
enddatetime2<-as.POSIXct(test$stopMeasurement, format="%d-%m-%Y %H:%M", tz="CET")

#https://stackoverflow.com/questions/43880823/subset-dataframe-based-on-posixct-date-and-time-greater-than-datetime-using-dply

# subset

dfsub <- df %>% dplyr::filter(timestamp >= startdatetime2 & timestamp <= enddatetime2)
dfsub


df<-read.csv("testdata/EP6_20_110_pol.csv")

df$dd.MM.yyyy
df$timestamp<-paste0(df$dd.MM.yyyy," ", substr(df$HH.mm.ss.SSSS,1,8))
 
 



