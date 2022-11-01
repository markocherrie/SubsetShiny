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

startdatetime<-reactive({
  sd<-as.POSIXct(paste0(input$startdate," ", input$starttime))
  sd
})

enddatetime<-reactive({
  ed<-as.POSIXct(paste0(input$enddate," ", input$endtime))
  ed
})

subdata<-reactive({

# Reactive file data
req(file_data())
df <- file_data()

# Reactive start datetime
req(startdatetime())
startdatetime<-startdatetime()

# Reactive end datetime
req(enddatetime())
enddatetime<-enddatetime()


# subset
dfsub <- subset(df, timestamp > startdatetime && timestamp < enddatetime)
dfsub
})

# Render the table
output$contents<-renderTable({
  subdata()
})
 
# Download function
output$downloadData <- downloadHandler(
  filename = function() {
    paste("EPHORdata-", Sys.Date(), ".csv", sep="", row.names=F)
  },
  content = function(file) {
    write.csv(subdata(), file)
  }
)


})