library(shiny)
library(shinyTime)
library(DT)

shinyUI(pageWithSidebar(
  # Title
  headerPanel("Subset your EPHOR data"),
  # User input
  sidebarPanel(
    fileInput("file1", "Upload Data",
              accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv")),
    dateInput("startdate", "Start Date:", format = "yyyy-mm-dd"),
    #Format is 00:00:00
    timeInput("starttime", "Start Time:"),
    
    dateInput("enddate", "End Date:", format = "yyyy-mm-dd"),
    #Format is 00:00:00 
    timeInput("endtime", "End Time:"),
    # Download button
    downloadButton("downloadData", "Download")
    
  ),
  
  mainPanel(

    tableOutput("contents"))
))