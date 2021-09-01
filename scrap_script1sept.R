# scrap1 <- 

# just testing if R Selenium in github actions is working
library(RSelenium)
library(seleniumPipes)
library(tidyverse)
library(dplyr)

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4444L,
  path = "/wd/hub",
  browserName = "chrome"
)
remDr$open()
remDr <- rD[["client"]]
# first getting testing data
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

