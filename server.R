# Load packages
library(shiny)
library(lubridate)
library(dplyr)

# server
shinyServer(function(input,output){
  
  
file_data <- reactive({
    req(input$file1)
    read.csv(input$file1$datapath, header = TRUE, sep = ",")
  })

file_name <- reactive({
  req(input$file1)
  fn<-(input$file1$datapath)
  return(fn)
})

startdatetime<-reactive({
  sd<-paste0(input$startdate," ", strftime(input$starttime, format="%H:%M:%S"))
  return(sd)
})
##### This bit is the problem!! - not recongising the hms
#####
enddatetime<-reactive({
  ed<-paste0(input$enddate," ", strftime(input$endtime, format="%H:%M:%S"))
  ed
})

subdata<-reactive({

# Reactive file data
req(file_data())
df <- file_data()

# Reactive start datetime
req(startdatetime())
startdatetime2<-startdatetime()

# Reactive end datetime
req(enddatetime())
enddatetime2<-enddatetime()

#https://stackoverflow.com/questions/43880823/subset-dataframe-based-on-posixct-date-and-time-greater-than-datetime-using-dply

# subset

dfsub <- df %>% dplyr::filter(timestamp >= startdatetime2 & timestamp <= enddatetime2)
dfsub
})

# Render the table
output$contents<-renderDataTable({
  subdata()
})
 

# Download function
output$downloadData <- downloadHandler(
  
  filename = function() {
    paste(gsub(".csv", "", input$file1$name), ".csv", sep="")
  },
  content = function(file) {
    write.csv(subdata(), file, row.names=F)
  }
)


})