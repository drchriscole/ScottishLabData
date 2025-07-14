library(DBI)

con <- dbConnect(RSQLite::SQLite(),
                 "ScotLabData.db")

## Load lab data
dash = read.csv("ExemplarTestData/DaSH.csv")
glasgow = read.csv("ExemplarTestData/Glasgow.csv")
hic = read.csv("ExemplarTestData/HIC.csv")
lothian = read.csv("ExemplarTestData/Lothian.csv")

dbWriteTable(con, 'DaSH', dash)
dbWriteTable(con, 'Glasgow', glasgow)
dbWriteTable(con, 'HIC', hic)
dbWriteTable(con, 'Lothian', lothian)

# Report counts for data
print("Loaded data entries...")
tableFunc <- function(x) {
    return(nrow(dbReadTable(con, name = x)))
}
sapply(c('DaSH', 'Glasgow', 'HIC', 'Lothian'), tableFunc)

## Load demography data
dash_dem = read.csv("ExemplarTestData/Demography_DaSH.csv")
glasgow_dem = read.csv("ExemplarTestData/Demography_Glasgow.csv")
hic_dem = read.csv("ExemplarTestData/Demography_HIC.csv")
lothian_dem = read.csv("ExemplarTestData/Demography_Lothian.csv")

dbWriteTable(con, 'Demography_DaSH', dash_dem)
dbWriteTable(con, 'Demography_Glasgow', glasgow_dem)
dbWriteTable(con, 'Demography_HIC', hic_dem)
dbWriteTable(con, 'Demography_Lothian', lothian_dem)

# Report counts for data
print("Loaded demography entries...")
sapply(c('Demography_DaSH', 'Demography_Glasgow', 'Demography_HIC', 'Demography_Lothian'), tableFunc)

## Load Lothian local code to read code mappings. Not required for others.
lothian_maps = read.delim("ExemplarTestData/Lothian_TestCode2ReadCode.tsv")
dbWriteTable(con, 'Lothian_TestCode2ReadCode', lothian_maps)

print("Loaded local code mapping entries...")
sapply(c('Lothian_TestCode2ReadCode'), tableFunc)
