library(shiny)
library(leaflet)
library(rCharts)
library(sqldf)
library(DT)

load("AppData.RData")


shinyServer( function(input, output) {
     
     output$map <- renderLeaflet({

        if(input$state == 'All'){
             myLat <- finalDS$CountyLat
             myLog <- finalDS$CountyLong
             location <- paste(finalDS$CountyName,paste("Total Population:",finalDS$TotalPopulation,sep=""),sep=", ")
             m <- leaflet()
             m <- addTiles(m)
             m <- addMarkers(m,lng=myLog, lat=myLat,
                             clusterOptions = markerClusterOptions(showCoverageOnHover = TRUE,
                                                                   zoomToBoundsOnClick = TRUE,
                                                                   spiderfyOnMaxZoom = TRUE,
                                                                   removeOutsideVisibleBounds = TRUE),
                             popup=location)
             
        }
        else {
             data <- subset(finalDS, finalDS$StateName == input$state)
             myLat <- data$CountyLat
             myLog <- data$CountyLong
             location <- paste(data$CountyName,paste("Total Population:",data$TotalPopulation,sep=""),sep=", ")
             m <- leaflet()
             m <- addTiles(m)
             m <- addMarkers(m,lng=myLog, lat=myLat,
                             clusterOptions = markerClusterOptions(showCoverageOnHover = TRUE,
                                                                   zoomToBoundsOnClick = TRUE,
                                                                   spiderfyOnMaxZoom = TRUE,
                                                                   removeOutsideVisibleBounds = TRUE),
                             popup=location)
         }
          
   })
     
   
   output$raceChart <- renderChart({
     if(input$state == "All"){
       data<- sqldf("select
                         'White' as Race,
                         sum(TotalWhite) as Population
                         from
                         finalDS
                         group by
                         'White'
                    
                          union all
                    
                    select
                         'Black' as Race,
                          sum(TotalBlack) as Population
                          from
                          finalDS
                          group by
                          'Black'
                    
                          union all
                    
                    select
                         'Indian' as Race,
                    sum(TotalIndian) as Population
                    from
                    finalDS
                    group by
                    'Indian'
                    
                    union all
                      
                    select
                         'Asian' as Race,
                    sum(TotalAsian) as Population
                    from
                    finalDS
                    group by
                    'Asian'
                    
                    union all
                    
                    select
                         'Hawaian/Islander' as Race,
                    sum(TotalHawaian) as Population
                    from
                    finalDS
                    group by
                    'Hawaian/Islander'
                    
                    union all
                    
                     select
                         'Hispanic' as Race,
                    sum(TotalHispanic) as Population
                    from
                    finalDS
                    group by
                    'Hispanic'
                    ")
        rCh <- nPlot(Population ~ Race,data=data,type='pieChart')
        rCh$set(dom = 'raceChart')
        rCh$params$width <- 500
        return(rCh)
     }
     else{
       data<-subset(finalDS,finalDS$StateName == input$state)
       data<- sqldf("select
                         'White' as Race,
                    sum(TotalWhite) as Population
                    from
                    data
                    group by
                    'White'
                    
                    union all
                    
                    select
                    'Black' as Race,
                    sum(TotalBlack) as Population
                    from
                    data
                    group by
                    'Black'
                    
                    union all
                    
                    select
                    'Indian' as Race,
                    sum(TotalIndian) as Population
                    from
                    data
                    group by
                    'Indian'
                    
                    union all
                    
                    select
                    'Asian' as Race,
                    sum(TotalAsian) as Population
                    from
                    data
                    group by
                    'Asian'
                    
                    union all
                    
                    select
                    'Hawaian/Islander' as Race,
                    sum(TotalHawaian) as Population
                    from
                    data
                    group by
                    'Hawaian/Islander'
                    
                    union all
                    
                    select
                    'Hispanic' as Race,
                    sum(TotalHispanic) as Population
                    from
                    data
                    group by
                    'Hispanic'
                    ")
       rCh <- nPlot(Population ~ Race,data=data,type='pieChart')
       rCh$set(dom = 'raceChart')
       rCh$params$width <- 500
       return(rCh)     
       
     }
   })
   
     
   output$dH <- renderText({
        if(input$state == "All"){
             "Population estimation by race"
        }
        else{paste("Population estimation by race in",input$state,sep=" ")}
   })
   

     
   output$table <- renderDataTable({
        if(input$state == "All"){
             data <- subset(finalDS,select=c("State","StateName","CountyName","CountyLat","CountyLong","TotalPopulation","TotalMale","TotalFemale","TotalWhite","TotalBlack","TotalAsian","TotalHispanic","TotalIndian","TotalHawaian"))
             names(data) <- c("State","State Name","County Name","County Latitude","County Longitude","Total Population","Male Population","Female Population","Est. White Population","Est. Black Population","Est. Asian Population","Est. Hispanic Population","Est. Indian Population","Est. Hawaian/Islander Population")
             DT::datatable(data)
        }
        else{
             data <- subset(finalDS,finalDS$StateName==input$state,select=c("State","StateName","CountyName","CountyLat","CountyLong","TotalPopulation","TotalMale","TotalFemale","TotalWhite","TotalBlack","TotalAsian","TotalHispanic","TotalIndian","TotalHawaian"))
             names(data) <- c("State","State Name","County Name","County Latitude","County Longitude","Total Population","Male Population","Female Population","Est. White Population","Est. Black Population","Est. Asian Population","Est. Hispanic Population","Est. Indian Population","Est. Hawaian/Islander Population")
             DT::datatable(data) 
        }
   })
   
   output$gender <- renderChart({
        if(input$state == "All"){
             data<- sqldf("select 
                         'Male' as Gender,
                          Sum(TotalMale) as Population
                          from 
                          finalDS
                          group by
                          'Male'
                          
                          union all                               
                          
                          select 
                          'Female' as Gender,
                          Sum(TotalFemale) as Population
                          from 
                          finalDS
                          group by
                          'Female'")
             gnd <- nPlot(Population ~ Gender,data=data,type='pieChart')
             gnd$set(dom = 'gender')
             gnd$params$width <- 500
             return(gnd)   
        }
        else{
             data <- subset(finalDS,finalDS$StateName == input$state)
             data <- sqldf("select 
                         'Male' as Gender,
                           Sum(TotalMale) as Population
                           from 
                           data
                           group by
                           'Male'
                           
                           union all                               
                           
                           select 
                           'Female' as Gender,
                           Sum(TotalFemale) as Population
                           from 
                           data
                           group by
                           'Female'")
             gnd <- nPlot(Population ~ Gender,data=data,type='pieChart')
             gnd$set(dom = 'gender')
             gnd$params$width <- 500
             return(gnd)   
        }
   })
   
   output$gn <- renderText({
        if(input$state == "All"){
             "Population by gender"
        }
        else{paste("Population by gender in",input$state,sep=" ")}
   })

})
