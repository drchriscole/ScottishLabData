library(DBI)
library(ggplot2)
library(ggpmisc)
library(patchwork)
library(dplyr)
con <- dbConnect(RSQLite::SQLite(),
                 "ScotLabData.db")

load("selectedCodes.RData")
ReadCodeList <- selectedCodes

# function to return recorded values for a given read code and safe haven
selectReadCode <- function(rc = '413L.', sh = 'DaSH') {
    stmt = sprintf("SELECT valueQuantity, :sh as SafeHaven 
                    FROM FHIR_%s 
                    WHERE code == :rc
                    AND valueQuantity is not NULL", sh)
    res <- dbGetQuery(con, stmt, list(rc = rc, sh = sh))
    res$valueQuantity <- as.numeric(res$valueQuantity)
    return(res)
}

for (code in ReadCodeList) {
    print(code)
    dash_rc = selectReadCode(rc = code, sh = 'DaSH')
    if (nrow(dash_rc) < 2) {
        print ("Fewer than two datapoints in DaSH")
    }
    glasgow_rc = selectReadCode(rc = code, sh = 'Glasgow')
    if (nrow(glasgow_rc) < 2) {
        print ("Fewer than two datapoints in Glasgow")
    }
    hic_rc = selectReadCode(rc = code, sh = 'HIC')
    if (nrow(hic_rc) < 2) {
        print ("Fewer than two datapoints in HIC")
    }
    lothian_rc = selectReadCode(rc = code, sh = 'Lothian')
    if (nrow(lothian_rc) < 2) {
        print ("Fewer than two datapoints in Lothian")
    }
    
    df = rbind(dash_rc, glasgow_rc, hic_rc, lothian_rc)
    if (nrow(df) == 0) {
        warning(paste(code,"has no data."))
        next
    }
    
    medians = df %>% group_by(SafeHaven) %>%
                summarise(median = median(valueQuantity))
    
    plt1 <- ggplot(df, aes(x=SafeHaven, y=valueQuantity)) +
       geom_boxplot()
    
    plt2 <- ggplot(df, aes(x=valueQuantity, colour=SafeHaven)) +
        geom_density(linewidth = 0.8) +
        annotate(geom = "table", x = max(df$valueQuantity), y = 0.02, label = list(medians))
    
    comb = plt1+ plt2
    
    comb + plot_annotation(
        title = paste('Read Code:', code)
    )

    ggsave(sprintf('plot/braw_%s.png',code), width = 2400, height = 1200, units = c("px"))
}
dbDisconnect(con)
