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
  
  # Meta data
  req(file2_data())
  metadata <- file2_data()
  
  # File name
  req(file1_data())
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
  
})

# reactive raw data
rawdatasubset<-reactive({
  
  # get the raw data
  req(file1_data())
  rawdata <- file1_data()
  
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
  })
  
  # Render the raw data table
  output$raw<-renderDataTable({
    rawdatasubset()
  })
  
  # render the meta data table
  output$meta<-renderDataTable({
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