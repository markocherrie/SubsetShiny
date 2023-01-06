# Load packages
library(shiny)
library(shinyTime)
library(DT)

shinyUI(pageWithSidebar(
  # Title
  headerPanel("Processing Low Cost Sensor data"),
  # User input
  sidebarPanel(
    helpText(""),
    selectInput("Data type", "Source of Data:",
                c("EPHOR Sensorbox" = "SB",
                  "Axivity" = "A",
                  "Polar" = "P")),
    fileInput("file2", "Upload Meta Data (list A)"), 
    fileInput("file1", "Upload Raw Data",
              accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv")), 
    #dateInput("startdate", "Start Date:", format = "yyyy-mm-dd"),
    #Format is 00:00:00
    #timeInput("starttime", "Start Time:"),
    #dateInput("enddate", "End Date:", format = "yyyy-mm-dd"),
    #Format is 00:00:00 
    #timeInput("endtime", "End Time:"),
    # Download button
    downloadButton("downloadData", "Download")
    
  ),
  
  # What will be shown in main panel
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("MetaData", DT::DTOutput("meta")),
                tabPanel("Data", DT::DTOutput("contents")),
                tabPanel("Plot", plotOutput("ggplott"))
    ))
))