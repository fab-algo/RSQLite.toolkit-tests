library(RSQLite.toolkit)
library(piggyback)

data_path <- "./data/src"
db_path <- "./data/sqlite"

pb_download(file="IT_INCOME_TAX_BY_AGE.zip", dest=data_path,
            repo="fab-algo/RSQLite.toolkit-tests")
unzip(zipfile=file.path(data_path, "IT_INCOME_TAX_BY_AGE.zip"), exdir=data_path)

in_files <- dir(path = file.path(data_path, "IT_INCOME_TAX_BY_AGE"),
                pattern = "cla_anno_tipo_reddito_[0-9]{4}\\.csv")

## ------------------------------------------
data_file <- file.path(data_path, "IT_INCOME_TAX_BY_AGE",
                       "cla_anno_tipo_reddito_2024.csv")

schema <- file_schema_dsv(input_file = data_file,
                          header = TRUE, sep = ";", dec = ",", grp = ".",
                          comment.char="")


new_names <- c("INCOME_GRP", "AGE_GRP", "NUM_IND", 
               "DOMAIN_INCOME_FRQ", "DOMAIN_INCOME_AMT", 
               "AGRIC_INCOME_FRQ", "AGRIC_INCOME_AMT", 
               "FARM_INCOME_FRQ", "FARM_INCOME_AMT", 
               "BUILDINGS_INCOME_FRQ", "BUILDINGS_INCOME_AMT", 
               "EMPLOYM_INCOME_FRQ", "EMPLOYM_INCOME_AMT", 
               "PENS_INCOME_FRQ", "PENS_INCOME_AMT", 
               "OTH_EMPLOY_INCOME_FRQ", "OTH_EMPLOY_INCOME_AMT", 
               "SELF_EMPL_INCOME_FRQ", "SELF_EMPL_INCOME_AMT", 
               "SELF_EMPL_LOSS_FRQ", "SELF_EMPL_LOSS_AMT", 
               "OTH_SELF_EMPL_1_INCOME_FRQ", "OTH_SELF_EMPL_1_INCOME_AMT", 
               "ENTREPR_1_INCOME_FRQ", "ENTREPR_1_INCOME_AMT", 
               "ENTREPR_2_INCOME_FRQ", "ENTREPR_2_INCOME_AMT", 
               "PARTIC_INCOME_FRQ", "PARTIC_INCOME_AMT", 
               "PARTIC_LOSS_FRQ", "PARTIC_LOSS_AMT", 
               "FIN_GAINS_FRQ", "FIN_GAINS_AMT", 
               "CAP_INCOME_FRQ", "CAP_INCOME_AMT", 
               "OTH_INCOME_FRQ", "OTH_INCOME_AMT", 
               "OTH_SELF_EMPL_2_INCOME_FRQ", "OTH_SELF_EMPL_2_INCOME_AMT", 
               "SEPARATE_TAXATION_FRQ", "SEPARATE_TAXATION_AMT"
               )


new_types <- schema$col_types
new_types[seq(from=5, to=41, by=2)] <- "numeric_grouped"

new_sql <- schema$sql_types
new_sql[seq(from=5, to=41, by=2)] <- "REAL"

schema$col_names <- new_names
schema$col_types <- new_types
schema$sql_types <- new_sql


## -----------------------------------------
dbcon <- dbConnect(dbDriver("SQLite"),
                   file.path(db_path, "IT_INCOME_TAX.sqlite"))

years <- as.integer(substr(x=in_files, start=23, stop=27))
table_name <- "INCOME_TAX_BY_AGE"

for (ii in 2:length(in_files)) {
    if (ii == 2) {
        drop_t <- TRUE
    } else {
        drop_t <- FALSE
    }
    cv <- data.frame(TAX_YEAR = c(years[ii]),
                     INCOME_YEAR = c(years[ii]-1))
    
    dbTableFromDSV(input_file=data_file, dbcon=dbcon, table_name=table_name,
                   header=TRUE, sep=";", dec=",", grp=".",
                   col_names=schema$col_names,
                   col_types=schema$col_types,
                   drop_table=drop_t,
                   constant_values = cv
                   )
}

df <- data.frame(table_name=table_name, schema)
dbTableFromDataFrame(df=df, dbcon=dbcon, table_name="TABLE_SCHEMA",
                     drop_table=TRUE, build_pk=TRUE,
                     pk_fields=c("table_name", "col_names"))

dbDisconnect(dbcon)






