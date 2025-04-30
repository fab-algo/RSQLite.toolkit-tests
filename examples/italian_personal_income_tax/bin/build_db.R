library(RSQLite.toolkit)

data_path <- "./data/src"
db_path <- "./data/sqlite"


## ------------------------------------------
library(piggyback)

pb_download(file="IT_INCOME_TAX_BY_AGE.zip", dest=data_path,
            repo="fab-algo/RSQLite.toolkit-tests")
unzip(zipfile=file.path(data_path, "IT_INCOME_TAX_BY_AGE.zip"),
      exdir=data_path)

pb_download(file="IT_INCOME_TAX_BY_MUNICIPALITY.zip", dest=data_path,
            repo="fab-algo/RSQLite.toolkit-tests")
unzip(zipfile=file.path(data_path, "IT_INCOME_TAX_BY_MUNICIPALITY.zip"),
      exdir=data_path)


## -----------------------------------------
dbcon <- dbConnect(dbDriver("SQLite"),
                   file.path(db_path, "IT_INCOME_TAX.sqlite"))






## ------------------------------------------
table_name <- "INCOME_BY_LEVEL_AND_AGE"

in_files <- dir(path = file.path(data_path, "IT_INCOME_TAX_BY_AGE"),
                pattern = "cla_anno_tipo_reddito_[0-9]{4}\\.csv")

data_file <- file.path(data_path, "IT_INCOME_TAX_BY_AGE",
                       in_files[2])

schema <- file_schema_dsv(input_file = data_file,
                          header = TRUE, sep = ";", dec = ",", grp = ".",
                          comment.char="")

new_names <- c("income_classes_eur",
               "age_classes",
               "num_taxpayers",
               "land_income_freq",
               "land_income_amt_eur",
               "agricultural_income_freq",
               "agricultural_income_amt_eur",
               "farming_income_freq",
               "farming_income_amt_eur",
               "property_income_freq",
               "property_income_amt_eur",
               "employment_income_freq",
               "employment_income_amt_eur",
               "pension_income_freq",
               "pension_income_amt_eur",
               "other_employment_income_freq",
               "other_employment_income_amt_eur",
               "self_employment_income_freq",
               "self_employment_income_amt_eur",
               "self_employment_loss_freq",
               "self_employment_loss_amt_eur",
               "other_self_employment_income_freq",
               "other_self_employment_income_amt_eur",
               "business_income_ordinary_freq",
               "business_income_ordinary_amt_eur",
               "business_income_simplified_freq",
               "business_income_simplified_amt_eur",
               "participation_income_freq",
               "participation_income_amt_eur",
               "participation_loss_freq",
               "participation_loss_amt_eur",
               "financial_gains_freq",
               "financial_gains_amt_eur",
               "capital_income_freq",
               "capital_income_amt_eur",
               "other_income_freq",
               "other_income_amt_eur",
               "other_self_employment_startup_income_freq",
               "other_self_employment_startup_income_amt_eur",
               "separate_taxation_option_freq",
               "separate_taxation_option_amt_eur")

new_types <- schema$col_types
new_types[seq(from=5, to=41, by=2)] <- "numeric_grouped"

new_sql <- schema$sql_types
new_sql[seq(from=5, to=41, by=2)] <- "REAL"

schema$col_names <- new_names
schema$col_types <- new_types
schema$sql_types <- new_sql


## -----------------------------------------
years <- as.integer(substr(x=in_files, start=23, stop=27))

for (ii in 2:length(in_files)) {
    if (ii == 2) {
        drop_t <- TRUE
    } else {
        drop_t <- FALSE
    }
    cv <- data.frame(tax_year = c(years[ii]),
                     income_year = as.integer(c(years[ii]-1)))
    
    data_file <- file.path(data_path, "IT_INCOME_TAX_BY_AGE",
                           in_files[ii])
    
    dbTableFromDSV(input_file=data_file, dbcon=dbcon, table_name=table_name,
                   header=TRUE, sep=";", dec=",", grp=".",
                   col_names=schema$col_names,
                   col_types=schema$col_types,
                   drop_table=drop_t,
                   constant_values = cv
                   )
}



## -----------------------------------------
data_file1 <- file.path(data_path, "IT_INCOME_TAX_BY_AGE",
                       "cla_anno_tipo_reddito_2018.csv")
schema1 <- file_schema_dsv(input_file = data_file1,
                          header = TRUE, sep = ";", dec = ",", grp = ".",
                          comment.char="")

col_import <- which(schema1$src_names %in% schema$src_names)
col_ignore <- setdiff(c(1:length(schema1$src_name)), col_import)

schema1$col_names[col_import] <- new_names
schema1$col_names[col_ignore] <- c("business_loss_simplified_freq",
                                   "business_loss_simplified_amt_eur"
                                   )

new_types1 <- schema1$col_types
new_types1[seq(from=5, to=43, by=2)] <- "numeric_grouped"
new_sql1 <- schema1$sql_types
new_sql1[seq(from=5, to=43, by=2)] <- "REAL"

schema1$col_types <- new_types1
schema1$sql_types <- new_sql1
 

dbTableFromDSV(input_file=data_file1, dbcon=dbcon, table_name=table_name,
               header=TRUE, sep=";", dec=",", grp=".",
               col_names = schema1$col_names,
               col_types = schema1$col_types,
               col_import = col_import,
               drop_table=FALSE,
               constant_values = data.frame(TAX_YEAR = c(2018),
                                            INCOME_YEAR = c(2017))
               )


## ------------------------------------------
df <- data.frame(table_name=table_name, schema)
dbTableFromDataFrame(df=df, dbcon=dbcon, table_name="TABLE_SCHEMA",
                     drop_table=TRUE, build_pk=TRUE,
                     pk_fields=c("table_name", "col_names"))









## ------------------------------------------
table_name <- "INCOME_TAX_BY_LEVEL_AND_AGE"

in_files <- dir(path = file.path(data_path, "IT_INCOME_TAX_BY_AGE"),
                pattern = "cla_anno_calcolo_irpef_[0-9]{4}\\.csv")

data_file <- file.path(data_path, "IT_INCOME_TAX_BY_AGE",
                       in_files[1])

schema <- file_schema_dsv(input_file = data_file,
                          header = TRUE, sep = ";", dec = ",", grp = ".",
                          comment.char="")

new_names <- c("income_classes_eur",
               "age_classes",
               "num_taxpayers",
               "total_income_freq",
               "total_income_amt_eur",
               "net_income_freq",
               "net_income_amt_eur",
               "home_deduction_freq",
               "home_deduction_amt_eur",
               "deductible_expenses_freq",
               "deductible_expenses_amt_eur",
               "taxable_income_freq",
               "taxable_income_amt_eur",
               "gross_tax_freq",
               "gross_tax_amt_eur",
               "tax_deductions_freq",
               "tax_deductions_amt_eur",
               "net_tax_freq",
               "net_tax_amt_eur",
               "tax_credits_withholdings_freq",
               "tax_credits_withholdings_amt_eur",
               "difference_freq",
               "difference_amt_eur",
               "prev_decl_excess_tax_freq",
               "prev_decl_excess_tax_amt_eur",
               "paid_advances_freq",
               "paid_advances_amt_eur",
               "irpef_credit_freq",
               "irpef_credit_amt_eur",
               "irpef_debt_freq",
               "irpef_debt_amt_eur"
               )

new_types <- schema$col_types
new_types[seq(from=5, to=31, by=2)] <- "numeric_grouped"

new_sql <- schema$sql_types
new_sql[seq(from=5, to=31, by=2)] <- "REAL"

schema$col_names <- new_names
schema$col_types <- new_types
schema$sql_types <- new_sql
 
## -----------------------------------------
years <- as.integer(substr(x=in_files, start=24, stop=28))

for (ii in 1:length(in_files)) {
    if (ii == 2) {
        drop_t <- TRUE
    } else {
        drop_t <- FALSE
    }
    cv <- data.frame(tax_year = c(years[ii]),
                     income_year = as.integer(c(years[ii]-1)))
    
    data_file <- file.path(data_path, "IT_INCOME_TAX_BY_AGE",
                           in_files[ii])
    
    dbTableFromDSV(input_file=data_file, dbcon=dbcon, table_name=table_name,
                   header=TRUE, sep=";", dec=",", grp=".",
                   col_names=schema$col_names,
                   col_types=schema$col_types,
                   drop_table=drop_t,
                   constant_values = cv
                   )
}


## ------------------------------------------
df <- data.frame(table_name=table_name, schema)
dbTableFromDataFrame(df=df, dbcon=dbcon, table_name="TABLE_SCHEMA",
                     drop_table=FALSE, build_pk=FALSE)




## -----------------------------------------
dbDisconnect(dbcon)

