# Load packages
library(shiny)
library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyr)

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
    paste(gsub(".csv", "", input$file1$name), "_subset.csv", sep="")
  },
  content = function(file) {
    write.csv(subdata(), file, row.names=F)
  }
)


output$ggplott <- renderPlot(

  subdata() %>%
    tidyr::pivot_longer(cols = temperature:sound)%>%
    filter(name %in% c('temperature','humidity','pressure','UVB','light','sound','PM2.5')) %>%
    ggplot(aes(x=timestamp,y=value)) +
    geom_point() +
    facet_grid(name ~.,scales = 'free_y') +
    theme(strip.text.y = element_text(angle = 0),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank()) +
      labs(y=NULL,x=NULL)
 
)

})