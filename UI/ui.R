library(shiny)
library(DT)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  titlePanel(title=div(img(src = "Logo.png", height = "50px"))),
  div(id = "vr-header"), 
    fluidRow(
      column(1, actionButton("sendMail", "Zu Event einladen!")),
      column(2, checkboxInput("doNameSearch", "Über Namen suchen:", FALSE))
    ),
    fluidRow(
      uiOutput("uiSearch")
    ),
    fluidRow(
      tags$br() 
    ),
    # Show a plot of the generated distribution
    fluidRow(
       column(5, DT::dataTableOutput("table")),
       column(7, leafletOutput("map", height = 1200))
    )
  )
)
