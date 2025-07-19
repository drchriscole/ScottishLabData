##### this file is for testing the sql server connection #######
####  as well as backup all necessary data in R as #############

## clear the workspace ######
rm(list = ls()); gc()

source("./R code for data harmonisation/0_functions.R")


######################################
#### Connecting to the SQL Server ####
######################################
#List drivers -check which ones are available
#sort(unique(odbcListDrivers()[[1]]))
######################################
######################################
#Set up the connection, uncomment when running example
library(DBI)
con <- dbConnect(RSQLite::SQLite(),
                 "ScotLabData.db")


# 14/12/2022
####################################################################
################# load demography data table #######################
####################################################################
#This reads the above table as defined under TblRead
Demography_HIC <- dbReadTable(con, "Demography_HIC")
Demography_Glasgow <- dbReadTable(con, "Demography_Glasgow")
Demography_Lothian <- dbReadTable(con, "Demography_Lothian")
Demography_DaSH <- dbReadTable(con, "Demography_DaSH")
#Demography_Lothian$anon_date_of_birth <- as.Date(as.character(Demography_Lothian$anon_date_of_birth),format = "%d/%m/%Y")
Demography_HIC$From <- "HIC"
Demography_Glasgow$From <- "Glasgow"
Demography_DaSH$From <- "DaSH"
Demography_Lothian$From <- "Lothian"
Demography <- rbind(Demography_HIC[,c("PROCHI", "sex", "anon_date_of_birth", "scsimd5","From")], 
                    Demography_Glasgow[,c("PROCHI", "sex", "anon_date_of_birth", "scsimd5","From")], 
                    Demography_Lothian[,c("PROCHI", "sex", "anon_date_of_birth", "scsimd5","From")], 
                    Demography_DaSH[,c("PROCHI", "sex", "anon_date_of_birth", "scsimd5","From")])
Demography <- unique(Demography)
save(Demography_HIC, Demography_Glasgow, Demography_Lothian, Demography_DaSH, Demography, file = "Demography.RData")
dbDisconnect(con)
