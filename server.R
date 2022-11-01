library(shiny)
library(plyr)
library(lubridate)
library(dplyr)

# server
shinyServer(function(input,output){
  
  
file_data <- reactive({
    req(input$file1)
    read.csv(input$file1$datapath, header = TRUE, sep = ",")
  })

startdatetime<-reactive({
  sd<-as.POSIXct(paste0(input$startdate," ", input$starttime))
  sd
})

enddatetime<-reactive({
  ed<-as.POSIXct(paste0(input$enddate," ", input$endtime))
  ed
})

subdata<-reactive({

# file data
req(file_data())
df <- file_data()

# start datetime
req(startdatetime())
startdatetime<-startdatetime()

# end datetime
req(enddatetime())
enddatetime<-enddatetime()


# subset
dfsub <- subset(df, timestamp > startdatetime && timestamp < enddatetime)
dfsub
})

output$contents<-renderTable({
  subdata()
})
 

output$downloadData <- downloadHandler(
  filename = function() {
    paste("EPHORdata-", Sys.Date(), ".csv", sep="", row.names=F)
  },
  content = function(file) {
    write.csv(subdata(), file)
  }
)


})