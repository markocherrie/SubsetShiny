# Load packages
library(shiny)
library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyr)
library(readxl)

# server
shinyServer(function(input,output){
  
  # fetch the uploaded raw data
  file1_data <- reactive({
    req(input$file1)
    read.csv(input$file1$datapath, header = TRUE, sep = ",")
  })
  
  # fetch the uploaded meta data
  file2_data <- reactive({
    req(input$file2)
    read_excel(input$file2$datapath)
  })
  
  typeofdata<-reactive({
    req(file1_data())
    typeofdata<-gsub(".csv", "", input$file1$name)
    typeofdata<-sub('.*\\_', '', typeofdata)
    typeofdata
  })
  
  
  # reactive meta data
  metadatasubset<-reactive({
    req(file1_data())
    
    if(grepl("^EP[[:digit:]]_[[:digit:]][[:digit:]]_[[:digit:]][[:digit:]][[:digit:]]_", input$file1$name, ignore.case = FALSE)==T){
      # Meta data
      req(file2_data())
      metadata <- file2_data()
      
      if(typeofdata()=="sen"){
        nameoffile<-gsub("_sen", "", input$file1$name)
      }else if(typeofdata()=="pol"){
        nameoffile<-gsub("_pol", "", input$file1$name)   
      }else if(typeofdata()=="act"){
        nameoffile<-gsub("_act", "", input$file1$name)
      }
      
      
      nameoffile<-gsub(".csv", "", nameoffile)
      
      # Subset meta data based on file name
      metadatasubset<-subset(metadata, participantID==as.character(nameoffile))
      metadatasubset
    } else {
      showModal(modalDialog(
        title = "Incorrect file name format",
        "The format of the file needs to be '[participantID]_[typeofsensor].csv'. The type of sensor can be sensorbox (_sen), polar (_pol) or axivity (_act).
       For example, if the participant ID was 'EP2_11_202' and data was from the sensorbox (_sen) the filename would be 'EP2_11_202_sen.csv'.",
        easyClose = TRUE,
        footer = "Please amend and re-upload"
      ))
    }
    
  })
  
  # reactive raw data
  rawdatasubset<-reactive({
    req(file1_data())
    
    if(grepl("^EP[[:digit:]]_[[:digit:]][[:digit:]]_[[:digit:]][[:digit:]][[:digit:]]_", input$file1$name, ignore.case = FALSE)==T){
      
      # get the raw data
      
      rawdata <- file1_data()
      
      validate(
        need(grepl("^EP", input$file1$name, ignore.case = TRUE)==T, "Please upload data in the following format: participantID_")
      )
      
      if(typeofdata()=="sen"){
        
        # filter the data
        rawdatasubset <- rawdata %>% dplyr::filter(timestamp >= as.POSIXct(metadatasubset()$startMeasurement, format="%d-%m-%Y %H:%M", tz="CET") & 
                                                     timestamp <= as.POSIXct(metadatasubset()$stopMeasurement, format="%d-%m-%Y %H:%M", tz="CET"))
        
        # detect outliers here?
        
      } else if(typeofdata()=="pol"){
        
        # process the polar data here
        
        
      } else if(typeofdata()=="act"){
        
        # process the axivity data here
        
      }
      
      rawdatasubset
    } else {
      showModal(modalDialog(
        title = "Somewhat important message",
        "This is a somewhat important message.",
        easyClose = TRUE,
        footer = NULL
      ))
    }
    
    
  })
  
  # Render the raw data table
  output$raw<-renderDataTable({
    req(rawdatasubset)
    rawdatasubset()
  })
  
  # render the meta data table
  output$meta<-renderDataTable({
    req(metadatasubset)
    metadatasubset()
  })
  
  
  # Render raw plot
  output$rawplot <- renderPlot(
    
    
    rawdatasubset() %>%
      tidyr::pivot_longer(cols = temperature:sound)%>%
      filter(name %in% c('temperature','humidity','pressure','UV_B','light','sound','PM2_5')) %>%
      mutate(timestamp=as.POSIXct(timestamp)) %>%
      ggplot(aes(x=timestamp,y=value)) +
      geom_point() +
      facet_grid(name~.,scales = 'free_y') +
      theme(strip.text.y = element_text(angle = 0, size=22), 
            axis.text.y = element_text(size=14),
            axis.text.x = element_text(angle = 45, hjust = 1,size = 16)) +
      labs(y=NULL,x=NULL) +
      scale_x_datetime(breaks = '12 hour', date_labels = '%d/%m %H:%M')
    
  )
  
  # Render downloaded data
  output$downloadData <- downloadHandler(
    
    filename = function() {
      paste(gsub(".csv", "", input$file1$name), "_subset.csv", sep="")
    },
    content = function(file) {
      write.csv(rawdatasubset(), file, row.names=F)
    }
  )
  
})