# 240, 130, 0

setwd("C:/Users/surface01/Documents/")
# runApp("PotentialNavigator")
library(shiny)
library(leaflet)
library(leaflet.extras)
library(DT)
library(digest)
library(RDCOMClient)


branchen = c("Tankstellen", "Spielwareneinzelhandel", "Sporteinzelhandel", "Sanitätsfachhandel",
             "Schuheinzelhandel", "Facheinzelhandel mit Nahrungs- und Genussmitteln", "Sortimentseinzel-
             handel mit Nahrungs- und Genussmitteln")

n = 300
set.seed(1)
dataRaw <- data.frame(
  name = paste0("Unternehmen", 1:n),
  lat = 51.343479 + rnorm(n, 0, 0.03),
  long = 12.387772 + rnorm(n, 0, 0.03),
  umsatz = sample(0:50000, n, replace = TRUE),
  entfernung = sample(0:100, n, replace = TRUE),
  bonitaet = sample(1:3, n, replace = TRUE),
  potential = sample(0:400, n, replace = TRUE),
  neuKunde = sample(c(T, F), n, replace = TRUE),
  branche = sample(branchen, n, replace = TRUE),
  gruendungsdatum = sample(1900:2005, n, replace = TRUE),
  mail = sample(c("andreastonio.liebrand@union-investment.de", "andreas.liebrand@hof.uni-frankfurt.de"), n, replace = TRUE),
  stringsAsFactors = FALSE
)

dataRaw2 <- read.csv2("C:/Users/surface01/Documents/daten5.csv", sep = ";", dec = ",",
                     encoding = "UTF-8", stringsAsFactors = FALSE, header = TRUE)
dataRaw$name <- dataRaw2$Column2
dataRaw$lat <- dataRaw2$lat
dataRaw$long <- dataRaw2$lng
dataRaw2$Umsatz.normiert <- gsub("[.]", "", dataRaw2$Umsatz.normiert)
dataRaw2$Umsatz.normiert <- gsub(" ", "", dataRaw2$Umsatz.normiert)
dataRaw$umsatz <- as.numeric(as.numeric(dataRaw2$Umsatz.normiert) / 1000000)
dataRaw2$Ertragspotenzial <- gsub("[.]", "", dataRaw2$Ertragspotenzial)
dataRaw2$Ertragspotenzial <- gsub(" ", "", dataRaw2$Ertragspotenzial)
dataRaw$potential <- as.numeric(dataRaw2$Ertragspotenzial)
dataRaw$umsatz <- as.numeric(as.numeric(dataRaw2$Umsatz.normiert) / 1000000)
dataRaw$branche <- dataRaw2$WZ
dataRaw$neuKunde[201] <- TRUE
dataRaw$long[177] <- dataRaw$long[178]
dataRaw$lat[177] <- dataRaw$lat[178]
dataRaw$long[202] <- dataRaw$long[203]
dataRaw$lat[202] <- dataRaw$lat[203]

# idx <- which(dataRaw$branche == "Industrie/ Handwerk")
# dataRaw[idx, ]$umsatz[dataRaw[idx, ]$umsatz >100] <- 12

getColor <- function(data) {
  sapply(dataRaw$neuKunde, function(neuKunde) {
    if(neuKunde) {
      "orange"
    } else {
      "blue"
    } 
  })
}

icons <- awesomeIcons(
  markerColor = getColor(data)
)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  observe({
    if(input$sendMail){
      OutApp <- COMCreate("Outlook.Application")
      outlookNameSpace <- OutApp$GetNameSpace("MAPI")
      outMail = OutApp$CreateItem(0)
      
      # Signature <- outMail[["HTMLbody"]]
      body <- "Was wollen wir denn in die Mail reinschreiben? :)."
      outMail[["subject"]] = "Insider Tipp: Wählen Sie den VR PotentialNavigator"
      outMail[["body"]] = "Sehr geehrtes Jury-Mitglied,

wir empfehlen Ihnen wärmstens den VR PotentialNavigator.

Als Firmenkundenberater haben Sie mit einem Klick alles im Blick.

Stimmen Sie für uns!

Ihr VR PotentialNavigator-Team
"
      
      outMail[["To"]] = paste(data()$mail, collapse = ";")
      outMail$Send()
    }
  })
  
  output$uiSearch <- renderUI({
    if(input$doNameSearch){
      return(
        column(2,
             selectizeInput("name",
                            "Unternehmensname:",
                            dataRaw$name, multiple = TRUE)
        )
      )
    }else{return(
      tagList(
        column(2, 
               sliderInput("umsatz",
                           "Umsatzerlöse:",
                           min = 5,
                           max = 15,
                           value = c(5, 15))
        ),
        column(2, 
               sliderInput("entfernung",
                           "Entfernung:",
                           min = min(dataRaw$entfernung),
                           max = max(dataRaw$entfernung),
                           value = c(min(dataRaw$entfernung), as.integer(0.6*max(dataRaw$entfernung))))
        ),
        column(2, 
               sliderInput("bonitaet",
                           "Bonität:",
                           min = min(dataRaw$bonitaet),
                           max = max(dataRaw$bonitaet),
                           value = c(min(dataRaw$bonitaet), max(dataRaw$bonitaet)),
                           step = 1)
        ),
        column(2,
               sliderInput("potential",
                           "Potential:",
                           min = 100,
                           max = 170,
                           value = c(110, 150))
        ),
        column(2,
               sliderInput("grDatum",
                           "Gruendungsdatum:",
                           min = min(dataRaw$gruendungsdatum),
                           max = max(dataRaw$gruendungsdatum),
                           value = c(min(dataRaw$gruendungsdatum), max(dataRaw$gruendungsdatum)))
        ),
        column(2,
          selectizeInput("branche", "Branche:", choices = unique(dataRaw$branche), multiple = TRUE)
        )
      )
    )
      
    }
  })
  
  output$table <- DT::renderDataTable({
    datatable(data()[c("name", "potential", "neuKunde", "branche")], options = list(pageLength = 25))
  })
   
  data <- reactive({
    # to do: probably needs refactoring
    if(!input$doNameSearch){
      if(!is.null(input$umsatz) & !is.null(input$potential) & !is.null(input$entfernung)){
        if(!length(input$branche)){
          FilterBranche = rep(TRUE, n)
        }else{
          FilterBranche = dataRaw$branche %in% input$branche 
        }
        FilterUmsatz <- dataRaw$umsatz >= input$umsatz[1] & dataRaw$umsatz <= input$umsatz[2]
        print(FilterUmsatz)
        FilterEntfernung <- dataRaw$entfernung >= input$entfernung[1] & dataRaw$entfernung <= input$entfernung[2]
        FilterBonitaet <- dataRaw$bonitaet >= input$bonitaet[1] & dataRaw$bonitaet <= input$bonitaet[2]
        FilterPotential <- dataRaw$potential >= input$potential[1] & dataRaw$potential <= input$potential[2]
        FilterDatum <- dataRaw$gruendungsdatum >= input$grDatum[1] & dataRaw$gruendungsdatum <= input$grDatum[2]
        Filter <- FilterUmsatz & FilterEntfernung & FilterBonitaet & FilterPotential & FilterDatum & FilterBranche
      }else{
        Filter = rep(TRUE, n)
      }
    }else{
      if(!length(input$name)){
        Filter = rep(TRUE, n)
      }else{
        Filter <- dataRaw$name %in% input$name
      }
    }
    dataRaw[Filter, ]
  })
  
  output$map <- renderLeaflet({
    data <- data()
    
    
    popupHtml <- '<table class="popup-table">
    <tr>
    <td width="50%%"></td><td align="right">
    <label for="id-of-input" class="custom-checkbox">
    <input type="checkbox" id="id-of-input"/>
    <i class="glyphicon glyphicon-star-empty"></i>
    <i class="glyphicon glyphicon-star"></i>
    </label>
    </td>
    </tr>
    <tr>
    <td>
    <h1>%s</h1>
    <br/>
    <b>Adresse:</b> %s
    <br/>
    <b>Ansprechpartner:</b> Max Mustermann
    <br/>
    <b>Website:</b> <a href="%s">%s</a>
    <br/>
    <b>Umsatz:</b> %s
    <br/>
    <b>Bonitaet:</b> %s
    <br/>
    <br/>
    <button>CreFo anfordern</button>
    </td>
    <td align="left">
    Ertragspotential:
    <img src="img/%s.png"></img>
    </td>'
    
    nameHash <- digest(data$name, algo="md5", serialize=F)
    filledPopupHtml <- sprintf(popupHtml, data$name, "Adresse TODO", data$umsatz, data$bonitaet, "http://www.google.com/", "http://www.google.com/", nameHash);
    
    map <- leaflet() %>%
      addTiles() %>%
      addAwesomeMarkers(lng = data$long, lat= data$lat, icon =icons, popup=filledPopupHtml, popupOptions = popupOptions(
        closeButton = FALSE,
        minWidth = 650,
        maxWidth = 650
      ))
    map <- addControlGPS(map, options = gpsOptions(position = "topleft", activate = TRUE,
                                                   autoCenter = TRUE, maxZoom = 10,
                                                   setView = TRUE))
    activateGPS(map)
    return(map)
  })
})




