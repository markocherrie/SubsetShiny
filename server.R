# Load packages
library(shiny)
library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyr)
library(readxl)

# server
shinyServer(function(input,output){
  
  
file1_data <- reactive({
    req(input$file1)
    read.csv(input$file1$datapath, header = TRUE, sep = ",")
  })


file2_data <- reactive({
  req(input$file2)
  read_excel(input$file2$datapath)
})


metadatasubset<-reactive({
  
  # Meta data
  req(file2_data())
  metadata <- file2_data()
  
  # File name
  req(file1_data())
  nameoffile<-gsub("_sen", "", input$file1$name)
  nameoffile<-gsub(".csv", "", nameoffile)
  
  # Subset meta data based on file name
  metadatasubset<-subset(metadata, participantID==as.character(nameoffile))
  metadatasubset
  
})

rawdatasubset<-reactive({
    
    
    # Raw data
    req(file1_data())
    rawdata <- file1_data()
  
    # filter the data
    rawdatasubset <- rawdata %>% dplyr::filter(timestamp >= as.POSIXct(metadatasubset()$startMeasurement, format="%d-%m-%Y %H:%M", tz="CET") & 
                                    timestamp <= as.POSIXct(metadatasubset()$stopMeasurement, format="%d-%m-%Y %H:%M", tz="CET"))
    rawdatasubset
  })
  
  # Render the raw data table
  output$raw<-renderDataTable({
    rawdatasubset()
  })
  
  # render the meta data table
  output$meta<-renderDataTable({
    metadatasubset()
  })
  
# Download function
output$downloadData <- downloadHandler(
    
    filename = function() {
      paste(gsub(".csv", "", input$file1$name), "_subset.csv", sep="")
    },
    content = function(file) {
      write.csv(subdata(), file, row.names=F)
    }
  )
  
  #breakpoint<-reactive({
  #x<-subdata() %>%
  #  mutate(timestamp=as.POSIXct(timestamp))
  #xy<-lubridate::day(max(x$timestamp)-min(x$timestamp))>=7
  #xy
  #})
  
  output$rawplot <- renderPlot(
    
    
    rawdatasubset() %>%
      tidyr::pivot_longer(cols = temperature:sound)%>%
      filter(name %in% c('temperature','humidity','pressure','UVB','light','sound','PM2.5')) %>%
      mutate(timestamp=as.POSIXct(timestamp)) %>%
      ggplot(aes(x=timestamp,y=value)) +
      geom_point() +
      facet_grid(name~.,scales = 'free_y') +
      theme(strip.text.y = element_text(angle = 0), axis.text.x = element_text(angle = 45, hjust = 1,size = 16)) +
      labs(y=NULL,x=NULL) +
      scale_x_datetime(breaks = '12 hour', date_labels = '%d/%m %H:%M')
    
  )
  
})