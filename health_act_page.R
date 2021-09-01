#https://raw.githubusercontent.com/amrrs/scrape-automation/main/nifty50_scraping.R

#load libs
library(plyr)
# library(tidyverse)
library(rvest)
# library(janitor)
# library(leaflet)
# library(ggmap)
# library(rvest)
library(RSelenium)
# library(tidyverse)
library(DescTools)
library(knitr)
# library(mapview)
library(arsenal)
# library(rgdal)
# library(dplyr)

# saveRDS(url_html, "data/test.rds")


#nse top gainers
url <- 'https://www.covid19.act.gov.au/'

# extract html 
url_html <- read_html(url)

#grab from website
es <- read_html("https://www.covid19.act.gov.au/act-status-and-response/act-covid-19-exposure-locations", )

#check update
ll <- es %>%
  html_nodes("strong") %>%
  html_text()
index <- grep("Page last updated:",ll)
dummy <- ll[index]
lup <- dummy
lu <- substr(strsplit(dummy,"updated:")[[1]][2],2,100)
lu <- gsub(" ", "_",lu)
lu <- gsub(":","",lu)
lu

#check if there was an update....
ff <- list.files("data/")
wu <- grep(lu, ff)
wu

# 0 = new data
# 1 = location update needed
# 2 = take NO action


##send email if wu == 1, or 2
#Code here...

#If wu = 1 then run the script below and check

##save data
if (length(wu)>2){
  print(paste0("All updated and synced with ACT update on ", lu)) 
}


#table extraction
##### scrape covid exposure table from website

#local run
# rD <- rsDriver(browser="firefox", port=4545L, verbose=FALSE)

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4444L,
  path = "/wd/hub",
  browserName = "chrome"
)

remDr <- rD[["client"]]

remDr$navigate("https://www.covid19.act.gov.au/act-status-and-response/act-covid-19-exposure-locations")

Sys.sleep(5) # give the page time to fully load

#click the archived button
#arch$clickElement()
#html <- remDr$getPageSource()[[1]]

html <- remDr$getPageSource()[[1]]
remDr$close()
rD$server$stop()
rm(rD)
gc()

#necessary to stop the server...
system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)

signals <- read_html(html)

tbls <- signals %>%
  html_nodes("table") %>%
  html_table(fill = TRUE)

tab3 <- data.frame(tbls)


#change empty to previous
tab3$Status <- ifelse(tab3$Status=="New","New","")
tab3$type <- paste(tab3$Contact, tab3$Status)


if (length(wu)==0)
{
  #folder path needs to change          
  write_csv(tab3,paste0('data/',Sys.Date(),'_act_location_run',lu, '.csv')) 
  #save last dataset
  write_csv(tab3, 'data/last_new.csv')
}

if (length(wu) == 1)
{
  ##run relocation script
  #send email
  #save last dataset
  # write_csv(tab3, 'data/last_new.csv') 
  print(paste0("New data needs to be check with ACT update on ", lu)) 
}



# ###todo check only new sites and not the once we have data from
# #load last.csv
# 
# ldata <- read.csv("data/last.csv")
# #check identical entries column Exposure.Location
# ldata$check <- paste(ldata$Exposure.Location, ldata$Street, ldata$Suburb, ldata$Date, ldata$Arrival.Time, ldata$Departure.Time)
# tab3$check <- paste(tab3$Exposure.Location, tab3$Street, tab3$Suburb, tab3$Date, tab3$Arrival.Time, tab3$Departure.Time)
# tab3 <- plyr::join(tab3, ldata[,c("lat","lon","check")],  by="check")
# tab3$check <- NULL
# ldata$check <- NULL
# 
# toadd <- which(is.na(tab3$lat))
# 
# #drop rows without 
# 
# # #function
# # fixgeo <- function(search,  lat, lon, column="Exposure.Location",tt=tab3) {
# #   
# #   ii <- NA
# #   ii <- grep(search,tt[,which(column==colnames(tab3))])
# #   if(length(ii>0)) {
# #     for (c in 1:length(ii)){
# #       tt[ii[c],"lat"] <-lat
# #       tt[ii[c],"lon"] <- lon
# #     }
# #   }
# #   return(tt)
# # }
# # 
# # #load google api
# # # gapi <- readLines("C://personalCODES/gapi.txt")
# # # register_google(gapi)
# # 
# # ##adding geocodes
# # #function
# # # new info to add
# # 
# # # #add lat lon
# # # #
# # # if (length(toadd)>0)
# # # {
# # #   tt <- tab3[toadd,]
# # #   #get coordinates only for those where lat lon is empty
# # # 
# # #   address <- geocode(paste0(tt$Street,", ", tt$Exposure.Location,", ",tt$Suburb ,", Canberra, Australia"))
# # # 
# # #   tab3$lat[toadd] <- address$lat
# # #   tab3$lon[toadd] <- address$lon
# # # }
# 
# if (length(wu)>2){
#   print(paste0("All updated and synced with ACT update on ", lu)) 
# }
# 
# 
# if (length(wu)==0)
# {
#  #folder path needs to change          
#  write_csv(tab3,paste0('data/',Sys.Date(),'_act_location_run',lu, '.csv')) 
#   #save last dataset
#   write_csv(tab3, 'data/last_new.csv')
# }
# 
#  if (length(wu) == 1)
#  {
#    ##run relocation script
#    #send email
#    #save last dataset
#     # write_csv(tab3, 'data/last_new.csv') 
#    print(paste0("New data needs to be check with ACT update on ", lu)) 
#  }
# 
#  
#  
#  
# #quickmap
# dat <- read.csv('data/last_new.csv')
# glimpse(dat)
#        
# 
# 
# ###############################################
# cols <- c( "red", "yellow","blue")
# 
# labs <- paste(tab3$Contact, tab3$Status,tab3$Exposure.Location, tab3$Street, tab3$Suburb, tab3$Date,tab3$Arrival.Time, tab3$Departure.Time, tab3$doubles, sep="<br/>") 
# cc <- as.numeric(factor(tab3$Contact,levels=c(  "Close"  , "Casual", "Monitor") ))
# ncols <- c("black","cyan")
# nn <- as.numeric(factor(tab3$Status))
# nn2 <- ifelse(nn==1,nn, 3)
# ##plot the map
# m <- leaflet() %>% addTiles()
# 
# m %>% addCircleMarkers(lat=tab3$lat, lng=tab3$lon,popup = labs, weight=nn2, fillColor = cols[cc],color=ncols[nn], opacity =0.8, radius = 5 , fillOpacity = 0.8)
# 
# 
# plotnow <- tab3 %>%
#             remove_missing() %>%
#               filter(Status == "New")
# 
# glimpse(plotnow)
# 
# totalnew <- tab3 %>%
#   # remove_missing() %>%
#   filter(Status == "New")
# 
# #11 repeat sites
# ##36 total == 25 new sites added
