library(shiny)
library(leaflet)
library(rCharts)
library(DT)

load("AppData.RData")

shinyUI(fluidPage(
     titlePanel("USA population analysis"),
     navbarPage("Menu",
          
          tabPanel("About",
                   sidebarPanel(p(span('This application is part of the final project for the course "Developing Data Products"
                                  provided by JHU and Coursera as part of the '), 
                                a("Data Sciense Specialization",href="https://www.coursera.org/specializations/jhu-data-science",target="_blank"),
                                span(".")),
                                p(span('It was created by'),
                                strong('Dimitrios Apostolopoulos'),
                                span(', BI Engineer since 2005, avid Coursera student since 2015 and Data Scientist to be.')),
                                p(span('You can find me in:'),br(),br(),
                                a(img(src = 'twitterLogo.png', height = 50, width = 60),href="https://twitter.com/dapostolopoylos",target="_blank"),
                                a(img(src = 'linkedinLogo.png', height = 50, width = 60),href="https://www.linkedin.com/in/dapostolop",target="_blank"))
                  ),
                  mainPanel(h2("About"),
                            p("The purpose of this application is to present a population analysis for the USA according to data collected from 
                              various sources.The reference year for the data presented is",strong("2014"),span(".")),
                            h3("Data Sources"),
                            p("The datasets used for this application are the following:"),
                            p(span("*   "),
                              a("CC-EST2014-ALLDATA.csv",href="https://www.census.gov/popest/data/counties/asrh/2014/files/CC-EST2014-ALLDATA.csv",target="_blank"),
                              span(": Downloaded from the "),
                              a("U.S. Census Bureau, Population Division", href="http://www.census.gov/popest/",target="_blank"),
                              span(",contains annual county resident population estimates by Age, Sex, Race, and Hispanic Origin from April 1, 2010 to July 1, 2014. 
                                   For the purpose of this application are used only the data of 2014.")),
                            p(span("*   "),
                              a("state_table.csv",href="http://statetable.com",target="_blank"),
                              span(": Downloaded from "),
                              a("StateTable.com", href="http://statetable.com",target="_blank"),
                              span(",contains a mapping for states and counties.")),
                            p(span("*   "),
                              a("state_latlon.csv",href="http://dev.maxmind.com/geoip/legacy/codes/state_latlon/",target="_blank"),
                              span(": Downloaded from "),
                              a("MaxMind",href="http://dev.maxmind.com/",target="_blank"),
                              span(",contains coordinates for every state.")),
                            p(span("*   "),
                              a("2015_Gaz_counties_national.txt",href="http://www.census.gov/geo/maps-data/data/gazetteer2015.html",target="_blank"),
                              span(": Downloaded from the "),
                              a("U.S. Census Bureau, Population Division", href="http://www.census.gov/popest/",target="_blank"),
                              span(",contains county geographical data.")),
                            h3("Application Features"),
                            p("The application consists of three tabs named", strong("About"),span(","),strong("Summarised Data"),span("and"),
                              strong("Detailed Data"),span(""),
                              h4("About"),
                              span("Is the current tab, it contains information about the author of the application as well
                                   as a full documentation about the application functionality and the data used for this application."),
                              h4("Summarised Data"),
                              span("It is the tab where all the visualization happens. It consists of a drop down state selector box, a map and two pie charts, 
                                   one visualizing estimation of USA population by race and the other actual population by gender."),
                              br(),br(),
                              span("When application loads we see an overall image of the USA population. On the map we see all the states clustered, choosing each cluster 
                              we drill down to the county level and we can see total population of each county by clicking on the pop up points. On the left side of the page
                              there is the selection drop down box where we can choose a specific state and focus the analysis and all the visualizations on our selection. 
                              All the visualizations are interactive and fully responsive to the selections we do in the selection box and so are also the descriptions of each pie chart. 
                              Regardless of the selections in the selections box, we can zoom in or zoom out in the map and navigate on it independantly. When hovering over a pie chart we can see
                                   the values of this part of the chart poping up."),
                              h4("Detailed Data"),
                              p("In this tab there is a table where there are displayed the data that are visualized in the application. The table is fully
                                responsive to the selections made in the selections box in the",strong("Summarised Data"),"tab.")
                            )
               )),
                     
          
          tabPanel("Summarised Data",
       
               fluidRow(
                    column(3,
                           selectInput(inputId = "state",
                                       label = "State selector",
                                       choices = na.omit(unique(sc$StateName)),
                                       selected= 'All')
                           ),
                    column(9,leafletOutput('map'))
               ),
               fluidRow(
                    column(width=6,h4(uiOutput("dH")),showOutput('raceChart', 'nvd3')),
                    column(width=6, h4(uiOutput("gn")),showOutput('gender', 'nvd3'))
                    )
               ),
          tabPanel("Detailed Data",
               fluidRow(width=12,dataTableOutput('table'))
          )
     )))