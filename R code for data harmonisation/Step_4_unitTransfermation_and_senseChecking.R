## clear the workspace ###################
rm(list = ls()); gc()

source("R code for data harmonisation/0_functions.R")

#Set up the connection, uncomment when running example
con <- dbConnect(RSQLite::SQLite(),
                 "ScotLabData.db")

######################################
#### unit and value transformation ###
######################################
# edit the following line accordingly to set path to Appendix B
unitchange <- read.csv("Paper Appendix/Appendix B.csv")

colnames(unitchange)[8] <- "Rule"
SHList <- c("HIC","Glasgow","Lothian","DaSH")
# dataframe to host data for censored data percentage
cenceredtest <- data.frame(SafeHaven = character(), code = character(), totaltest = double(), censoredtest = double())
# dataframe to host data for unit transfer data lost
unittransferdatalose <- data.frame(SafeHaven = character(), code = character(), totaltest = double(), afterunittransfer = double())
###### loop #########################
load("selectedCodes.RData")
ReadCodeList <- selectedCodes
for (SH in SHList) {
    i=1
    for (rc in ReadCodeList) {
      s = sprintf("%3d %s", i, rc)
      print(s)
      unitinfor <- unitchange[unitchange$ReadCode==rc,]
      Q = paste0("SELECT * FROM FHIR_", SH," WHERE code = '", rc,"'")
      data <- dbGetQuery(con, Q)
      data[,"valueQuantity"] <- as.double(as.character(data[,"valueQuantity"]))
      data$originalValueQuantity <- data$valueQuantity
      dimoriginal <- dim(data)      # calculate how many records before change
      data <- unitTransferFunction(data,unitinfor,rc)
      ## calculate the percentage of records lose through unit transer
      d <- data.frame(SafeHaven = SH) 
      d$code <- rc
      d$totaltest <- dimoriginal[1]
      d$afterunittransfer <- dim(data)[1]
      unittransferdatalose <- rbind(unittransferdatalose,d)
      #############################################
      data <- outlierCutFunction(data)
      data <- CensoredValueFunction(data)
      ## calculate the percentage of censored value
      d <- data.frame(SafeHaven = SH) 
      d$code <- rc
      d$totaltest <- dim(data)[1]
      d$censoredtest <- dim(data[data$valueQuantity!=data$originalValueQuantity,])[1]
      cenceredtest <- rbind(cenceredtest,d)
      #############################################
      save(data, file = paste0("./data/",SH,"_",rc,"D.RData"))
      ##D_t <- rbind(D_t,data)
      i=i+1
      
    }
    save(cenceredtest, file ="cenceredtest.RData" )
    save(unittransferdatalose, file ="unittransferdatalose.RData" )

}

