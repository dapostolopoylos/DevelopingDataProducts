# Set working directory.
setwd("G:/Developing Data Products/CourseProject")

# Load libraries.
library(sqldf)
library(RCurl)

# Load county data downloaded from http://www.census.gov/geo/maps-data/data/gazetteer2015.html
if (!exists("countyData")){
     countyData <-read.table("./data/2015_Gaz_counties_national.txt", 
                             sep="\t",
                             header=TRUE,
                             stringsAsFactors = FALSE,
                             quote="")
}

# Load coordinates for every state downloaded from http://dev.maxmind.com/geoip/legacy/codes/state_latlon/.
if (!exists("stateCoord")){
     stateCoord <-read.csv("./data/state_latlon.csv", 
                             sep=",",
                             header=TRUE,
                             stringsAsFactors = FALSE)
}

# Load population data downloaded from http://www.census.gov/popest/data/counties/asrh/2014/files/CC-EST2014-ALLDATA.csv.
if(!file.exists("./data/CC-EST2014-ALLDATA.csv")){
  URL<-"https://www.census.gov/popest/data/counties/asrh/2014/files/CC-EST2014-ALLDATA.csv"
  x <- getURL(URL, ssl.verifypeer = FALSE)
  data <- read.csv(textConnection(x))
  data <- sqldf("select * from data where YEAR=7 and AGEGRP=0")
  write.csv(data,"./data/CC-EST2014-ALLDATA.csv",row.names = FALSE)
  rm(x,URL,data)  
}

if (!exists("populationData")){
    populationData <- read.csv("./data/CC-EST2014-ALLDATA.csv", 
                               sep=",",
                               header=TRUE,
                               stringsAsFactors = FALSE) 
     
    populationData<-sqldf("select 
                                   STNAME as 'State',
                                   CTYNAME as 'County',
                                   TOT_POP as 'TotalPopulation',
                                   TOT_MALE as 'TotalMale',
                                   TOT_FEMALE as 'TotalFemale',
                                   WA_MALE + WA_FEMALE as 'TotalWhite',
                                   BA_MALE + BA_FEMALE as 'TotalBlack',
                                   IA_MALE + IA_FEMALE as 'TotalIndian',
                                   AA_MALE + AA_FEMALE as 'TotalAsian',
                                   NA_MALE + NA_FEMALE as 'TotalHawaian',
                                   H_MALE + H_FEMALE as 'TotalHispanic'
                              from 
                                   populationData")
}


# Load long names of US states downloaded from http://statetable.com
if (!exists("stateNames")){
     stateNames <- read.csv("./data/state_table.csv",
                            sep=",",
                            header = TRUE,
                            stringsAsFactors = FALSE)
     stateNames <- subset(stateNames,select=c(name,abbreviation))
}

# Create final data set.
if (!exists("finalDS")){
     finalDS <- sqldf("select
                         cD.USPS as 'State',
                         CASE
                              WHEN cD.NAME = 'District of Columbia'
                              THEN 'District of Columbia'
                              ELSE sN.name
                         END AS StateName,
                         cD.NAME as 'CountyName',
                         cD.INTPTLAT as 'CountyLat',
                         cD.INTPTLONG as 'CountyLong',
                         sC.latitude as 'StateLat',
                         sC.longitude as 'StateLong'
                       from
                         countyData as cD
                         left join stateCoord as sC
                         on cD.USPS = sC.state
                         left join stateNames as sN
                         on cD.USPS = sN.abbreviation")
     
     finalDS <- sqldf("Select
                         fDS.State,
                         CASE
                              WHEN fDS.CountyName = 'District of Columbia'
                              THEN 'District of Columbia'
                              ELSE fDS.StateName
                         END AS StateName,
                         fDS.CountyName,
                         CASE 
                              WHEN fDS.State = 'AK' and fDS.CountyName = 'Aleutians West Census Area' 
                              THEN '53.922737'
                              ELSE fDS.CountyLat
                         END AS CountyLat,
                         CASE 
                              WHEN fDS.State = 'AK' and fDS.CountyName = 'Aleutians West Census Area' 
                              THEN '-166.297006'
                              ELSE fDS.CountyLong
                         END AS CountyLong,
                         fDS.StateLat,
                         fDS.StateLong,
                         pD.TotalPopulation,
                         pD.TotalMale,
                         pD.TotalFemale,
                         pD.TotalWhite,
                         pD.TotalBlack,
                         pD.TotalIndian,
                         pD.TotalAsian,
                         pD.TotalHawaian,
                         pD.TotalHispanic
                       from
                         finalDS as fDS
                         left join populationData as pD
                         on trim(fDS.StateName)=trim(pD.State)
                         and 
                         trim(fDS.CountyName)=trim(pD.County)")

}

sc <- rbind(sqldf("select distinct 
                         StateName,
                         CountyName
                   from 
                         finalDS 
                   order by 
                         StateName,
                         CountyName asc"),c("All","All"))

rm(countyData,populationData,stateCoord,stateNames)

save.image("./USAPopAppp/AppData.RData")
