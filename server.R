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


metasub<-reactive({
  
  # meta data here
  req(file2_data())
  df2 <- file2_data()
  
  # Reactive file data
  req(file1_data())
  test2<-input$file1$name
  test2<-gsub("_sen", "", test2)
  test2<-gsub(".csv", "", test2)
  
  # subset
  test<-subset(df2, participantID==as.character(test2))
  test
  
})

subdata<-reactive({
    
    
    # Reactive file data
    req(file1_data())
    df <- file1_data()
    
    # Reactive start datetime
    startdatetime2<-metasub()$startMeasurement
    enddatetime2<-metasub()$stopMeasurement
    
    #https://stackoverflow.com/questions/43880823/subset-dataframe-based-on-posixct-date-and-time-greater-than-datetime-using-dply
    # Reactive start datetime
    startdatetime2<-as.POSIXct(startdatetime2, format="%d-%m-%Y %H:%M", tz="CET")
    enddatetime2<-as.POSIXct(enddatetime2, format="%d-%m-%Y %H:%M", tz="CET")
    # subset
    
    dfsub <- df %>% dplyr::filter(timestamp >= startdatetime2 & timestamp <= enddatetime2)
    dfsub
  })
  
  # Render the table
  output$contents<-renderDataTable({
    subdata()
  })
  
  
  output$meta<-renderDataTable({
    metasub()
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
  
  output$ggplott <- renderPlot(
    
    
    subdata() %>%
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