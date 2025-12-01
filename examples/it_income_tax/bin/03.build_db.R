library(here)
library(RSQLite.toolkit)
library(openxlsx2)

here::i_am("README.md")
example_path <- here::here("examples", "it_income_tax")

## ------------------------------------------
source(here(example_path, "bin", "00.utils.R"))

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
make_table <- function(map, dbcon, add_tax_year = FALSE) {

    tbl_def <- unique(map[, c("tgt_col_name", "col_type", "col_order")])
    tbl_def <- tbl_def[order(tbl_def$col_order), ]
    tbl_def <- data.frame(
        col_names = tbl_def$tgt_col_name,
        col_types = tbl_def$col_type,
        sql_types = R2SQL_types(tbl_def$col_type),
        stringsAsFactors = FALSE, row.names = NULL
    )

    sql.def <- paste("DROP TABLE IF EXISTS ", table_name, ";", sep = "")
    dbExecute(dbcon, sql.def)

    sql.head <- paste("CREATE TABLE IF NOT EXISTS ", table_name, " (", sep = "")
    sql.body <- paste(tbl_def$col_names, tbl_def$sql_types,
        sep = " ",
        collapse = ", "
    )
    if (add_tax_year) {
        sql.body <- paste(sql.body, ", tax_year INTEGER", sep = "")
    }   
    sql.tail <- ");"

    sql.def <- paste(sql.head, sql.body, sql.tail, sep = " ")
    dbExecute(dbcon, sql.def)
}





## ------------------------------------------
read_files <- function(table_name, dbcon, map, in_path, in_files, 
                       f_encodings, quote2, grp2, add_tax_year = FALSE) {

    ll <- regexpr(text=in_files, pattern="_[0-9]{4}\\.")
    idx <- which(ll > 0)    
    if (length(idx) == 0) {
        stop("No files found with the expected pattern.")
    }
    years <- as.integer(
        substr(x = in_files[idx], start = ll[idx] + 1, stop = ll[idx] + 5)
    )

    for (ii in 1:length(in_files)) {
        drop_t <- FALSE

        data_file <- file.path(in_path, in_files[ii])

        schema <- file_schema_dsv(
            input_file = data_file,
            header = TRUE, sep = ";", dec = ",", grp = grp2,
            quote = quote2, na.strings = "", comment.char = "",
            fileEncoding = f_encodings[ii]
        )

        schema_mapped <- merge(
            x = schema$schema,
            y = map,
            by.x = "col_names", by.y = "src_col_name",
            all.x = TRUE, all.y = FALSE,
            sort = FALSE
        )

        idx <- which(is.na(schema_mapped$tgt_col_name))
        if (length(idx) > 0) {
            warning(paste(
                kk, ii, "The following columns are not mapped in the schema: ",
                paste(schema_mapped$col_names[idx], collapse = ", ")
            ))
        }

        if (add_tax_year) {
            cv <- data.frame(tax_year = c(years[ii]))
        } else {
            cv <- NULL
        }

        dbTableFromDSV(
            input_file = data_file, dbcon = dbcon, table_name = table_name,
            header = TRUE, sep = ";", dec = ",", grp = grp2,
            quote = quote2, na.strings = "", comment.char = "",
            fileEncoding = f_encodings[ii],
            col_names = schema_mapped$tgt_col_name,
            col_types = schema_mapped$col_type,
            drop_table = drop_t,
            constant_values = cv
        )
        
    }
}






## ------------------------------------------
table_name <- "INCOME_TAX_BY_MUNICIPALITY"

in_path <- here(data_path, "IT_INCOME_TAX_BY_MUNICIPALITY")
in_files <- dir(path = in_path,
                pattern = ".*base_comunale_CSV_[0-9]{4}\\.csv")

add_tax_year <- FALSE

f_encodings <- c(rep("ISO_8859-1", times=6), 
                 rep("US-ASCII", times=3),
                 rep("ISO_8859-1", times=3), 
                 rep("US-ASCII", times=12))

map_file <- file.path(
    example_path, "wrk",
    "INCOME_TAX_BY_MUNICIPALITY_col_names_map.xlsx"

)
map <- openxlsx2::wb_to_df(
    file = map_file, sheet = "col_names_map",
    start_row = 1, cols = 1:4,
    col_names = TRUE, row_names = FALSE
)

make_table(map = map, dbcon = dbcon, add_tax_year = add_tax_year)

read_files(table_name, dbcon, map, in_path, in_files, 
           f_encodings, quote2 = "\"", grp2 = "", 
           add_tax_year=add_tax_year)




## ------------------------------------------
table_name <- "INCOME_TAX_BY_LEVEL_AND_AGE"

in_path <- here(data_path, "IT_INCOME_TAX_BY_AGE")
in_files <- dir(path = in_path,
                pattern = "cla_anno_calcolo_irpef_[0-9]{4}\\.csv")

add_tax_year <- TRUE

f_encodings <- rep("UTF-8", times=length(in_files))

map_file <- file.path(
    example_path, "wrk",
    "INCOME_TAX_BY_LEVEL_AND_AGE_col_names_map.xlsx"

)
map <- openxlsx2::wb_to_df(
    file = map_file, sheet = "col_names_map",
    start_row = 1, cols = 1:4,
    col_names = TRUE, row_names = FALSE
)

make_table(map = map, dbcon = dbcon, add_tax_year = add_tax_year)

read_files(table_name, dbcon, map, in_path, in_files, 
           f_encodings, quote2 = "\"", grp2 = ".", 
           add_tax_year = add_tax_year)







## ------------------------------------------
dbDisconnect(dbcon)

