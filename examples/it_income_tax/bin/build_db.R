library(here)
library(RSQLite.toolkit)
library(openxlsx2)

here::i_am("README.md")
example_path <- here::here("examples", "it_income_tax")

## ------------------------------------------
data_path <- here(example_path, "data/src")
db_path <- here(example_path, "data/sqlite")

if (!dir.exists(data_path)) {
    dir.create(path = data_path, recursive = TRUE)
}
 
if (!dir.exists(db_path)) {
    dir.create(path = db_path, recursive = TRUE)
}

dbcon <- dbConnect(SQLite(),
                   here(db_path, "IT_INCOME_TAX.sqlite"))

## ------------------------------------------
library(piggyback)

pb_download(file="IT_INCOME_TAX_BY_AGE.zip", dest=data_path,
            repo="fab-algo/RSQLite.toolkit-tests")
unzip(zipfile=here(data_path, "IT_INCOME_TAX_BY_AGE.zip"),
      exdir=data_path)

pb_download(file="IT_INCOME_TAX_BY_MUNICIPALITY.zip", dest=data_path,
            repo="fab-algo/RSQLite.toolkit-tests")
unzip(zipfile=here(data_path, "IT_INCOME_TAX_BY_MUNICIPALITY.zip"),
      exdir=data_path)

pb_download(file="ISTAT_Municipalities_Classification.zip", dest=data_path,
            repo="fab-algo/RSQLite.toolkit-tests")
unzip(zipfile=here(data_path, "ISTAT_Municipalities_Classification.zip"),
      exdir=data_path)




## ------------------------------------------
table_name <- "INCOME_TAX_BY_MUNICIPALITY"


## ------------------------------------------
in_files <- dir(path = here(data_path, "IT_INCOME_TAX_BY_MUNICIPALITY"),
                pattern = ".*base_comunale_CSV_[0-9]{4}\\.csv")

f_encodings <- c(rep("ISO_8859-1", times=6), 
                 rep("US-ASCII", times=3),
                 rep("ISO_8859-1", times=3), 
                 rep("US-ASCII", times=12))


## ------------------------------------------
schemas <- list()
col_counts <- data.frame(file_num = integer(),
                         Num_col = integer(),
                         Freq = integer())
col_names <- character()

for (ii in 1:length(in_files)) {
    data_file <- here(data_path, "IT_INCOME_TAX_BY_MUNICIPALITY",
                           in_files[ii])
    
    schema <- file_schema_dsv(input_file = data_file,
                              header = TRUE, sep = ";", dec = ",", grp = "",
                              quote="", na.strings="", comment.char="",
                              fileEncoding = f_encodings[ii])

    col_counts <- rbind(col_counts, data.frame(file_num =  ii,
                                               schema$col_counts)
                        )

    col_names <- unique(c(col_names, schema$schema$col_names))

    schema <- append(x = schema, values = c(input_file=data_file), after=0)

    schemas <- append(x = schemas,
                      values = list(schema)
                      )

}

names(schemas) <- paste0("file_", 1:length(in_files))

col_names <- col_names[order(col_names)]
col_names <- data.frame(col_names,
                        matrix(data = 0L,
                               nrow = length(col_names),
                               ncol = length(in_files)),
                        stringsAsFactors=FALSE)

for (ii in 1:length(in_files)) {
    cur_names <- schemas[[ii]]$schema$col_names
    idx <- which(col_names$col_names %in% cur_names)
    col_names[idx, ii+1] <- match(col_names$col_names[idx], cur_names)
}

write_xlsx(x = col_names,
           file = here(example_path, "wrk", paste0(table_name, "_col_names.xlsx")),
           sheet = "col_names"
           )


## ------------------------------------------
R2SQL_types <- function(x) {
    r2sql_dict <- c("character"= "TEXT",
                    "double"   = "REAL",
                    "integer"  = "INTEGER",
                    "logical"  = "INTEGER",
                    "numeric"  = "REAL",
                    "Date"     = "DATE",
                    "double_grouped"   = "REAL",
                    "integer_grouped"  = "INTEGER",
                    "numeric_grouped"  = "REAL")
    
    y <- r2sql_dict[x]
    y[which(is.na(y))] <- "TEXT"

    y    
}

data_file <- file.path(example_path, "wrk", "INCOME_TAX_BY_MUNICIPALITY_col_names_map.xlsx")

map <- wb_to_df(file = data_file, sheet = "col_names_map",
                start_row = 1, cols = 1:4, 
                col_names = TRUE, row_names = FALSE) 


tbl_def <- unique(map[, c("tgt_col_name", "col_type", "col_order")])
tbl_def <- tbl_def[order(tbl_def$col_order), ]

tbl_def <- data.frame(col_names = tbl_def$tgt_col_name,
                      col_types = tbl_def$col_type,
                      sql_types = R2SQL_types(tbl_def$col_type),
                      stringsAsFactors=FALSE, row.names = NULL)

sql.def <- paste("DROP TABLE IF EXISTS ", table_name, ";", sep = "")
dbExecute(dbcon, sql.def)

sql.head <- paste("CREATE TABLE IF NOT EXISTS ", table_name, " (", sep = "")
sql.body <- paste(tbl_def$col_names, tbl_def$sql_types, sep = " ",
                  collapse = ", ")
sql.tail <- ");"

sql.def <- paste(sql.head, sql.body, sql.tail, sep = " ")
dbExecute(dbcon, sql.def)


## ------------------------------------------
years <- as.integer(substr(x=in_files, start=59, stop=62))

for (ii in 1:length(in_files)) {
    drop_t <- FALSE
 
    data_file <- file.path(data_path, "IT_INCOME_TAX_BY_MUNICIPALITY",
                           in_files[ii])

    schema <- file_schema_dsv(input_file = data_file,
                              header = TRUE, sep = ";", dec = ",", grp = "",
                              quote="", na.strings="", comment.char="",
                              fileEncoding = f_encodings[ii])
    
    schema_mapped <- merge(
        x = schema$schema,
        y = map,
        by.x = "col_names", by.y = "src_col_name",
        all.x = TRUE, all.y = FALSE,
        sort = FALSE
    )

    idx <- which(is.na(schema_mapped$tgt_col_name))
    if (length(idx) > 0) {
        warning(paste(ii, "The following columns are not mapped in the schema: ",
                      paste(schema_mapped$col_names[idx], collapse=", ")))
    }

    dbTableFromDSV(input_file=data_file, dbcon=dbcon, table_name=table_name,
                   header=TRUE, sep=";", dec=",", grp=".",
                   quote="\"", na.strings="", comment.char="",
                   fileEncoding = f_encodings[ii],
                   col_names=schema_mapped$tgt_col_name,
                   col_types=schema_mapped$col_type,
                   drop_table=drop_t
                   )
}

dbDisconnect(dbcon)

