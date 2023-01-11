# Load packages
library(shiny)
library(shinyTime)
library(DT)
library(shinycssloaders)

shinyUI(pageWithSidebar(
  # Title
  headerPanel("Low Cost Sensor Data Processing"),
  # User input
  sidebarPanel(
    helpText(""),
    fileInput("file2", "Upload Measurement Data (list A)"), 
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
                tabPanel("Measurement Data", DT::DTOutput("meta")),
                tabPanel("Raw Data", DT::DTOutput("raw")),
                tabPanel("Raw Data Plot", withSpinner(plotOutput("rawplot", height=750)))
    ))
))