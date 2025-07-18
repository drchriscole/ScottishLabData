
##
## This script calculates read code aggregate counts and saves to the db.
##

library(DBI)
source("ExemplarTestData/canned_sql.R")

con <- dbConnect(RSQLite::SQLite(),
                 "ScotLabData.db")

dbExecute(con, createReadCodeTable('DaSH'))
dbExecute(con, createReadCodeTable('Glasgow'))
dbExecute(con, createReadCodeTable('HIC'))
dbExecute(con, createReadCodeTable('Lothian'))

dbDisconnect(con)
