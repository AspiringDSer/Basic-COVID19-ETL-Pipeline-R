# COVID-19 ETL Pipeline 

library(utils)
library(RMySQL)
library(DBI)
library(taskscheduleR)

# Schedule Automate Update
taskscheduler_create(taskname = "covid-data-update", rscript = "covid-19-ETL-script.R", 
                     schedule = "DAILY", startime = "09:10", starttime = format(Sys.time() + 1, "%m/%d/%Y"))

# Stop and Delete Scheduler 
#taskcheduler_stop("covid-data-update")
#taskscheduler_delete("covid-data-update")

# Pull Data
data <- read.csv("https://opendata.ecdc.europa.eu/covid19/nationalcasedeath_eueea_daily_ei/csv", na.strings = "", fileEncoding = "UTF-8-BOM")
write.csv(data, "covid-19-data.csv", row.names = FALSE)

# Connect MySQL
con <- dbConnect(RMySQL::MySQL(),
        host = "localhost",
        port = 3306,
        user = "root",
        password = "rootroot")

# Creating Database
dbSendQuery(con, "DROP DATABASE IF EXISTS COVID_ETL_PIPELINE_R")
dbSendQuery(con, "CREATE DATABASE COVID_ETL_PIPELINE_R")
dbSendQuery(con, "USE COVID_ETL_PIPELINE_R")

# Reconnecting to Database
mydb = dbConnect(RMySQL::MySQL(),
        dbname = "COVID_ETL_PIPELINE_R",
        host = "localhost",
        port = 3306,
        user = "root",
        password = "rootroot")

# Creating Table 
dbSendQuery(mydb, "DROP TABLE IF EXISTS data")
dbWriteTable(mydb, "data", data, overwrite=TRUE, row.names = FALSE)


