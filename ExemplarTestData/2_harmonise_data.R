library(DBI)
source('ExemplarTestData/canned_sql.R')

##
## This script takes the loaded data and harmonises to a FHIR-like structure
##

con <- dbConnect(RSQLite::SQLite(),
                 "ScotLabData.db")

# DaSH
dbExecute(con, sql_create_dashv2)
dbExecute(con, sql_create_fhir_dash)
nrows = dbExecute(con, sql_insert_fhir_dash)

# Glasgow
dbExecute(con, sql_create_fhir_glasgow)
dbExecute(con, sql_insert_fhir_glasgow)

# HIC
dbExecute(con, sql_create_fhir_hic)
dbExecute(con, sql_insert_fhir_hic_biochem)

# Lothian
dbExecute(con, sql_create_lothian_readcode)
dbExecute(con, sql_create_fhir_lothian)
dbExecute(con, sql_insert_fhir_lothian)

dbDisconnect(con)
