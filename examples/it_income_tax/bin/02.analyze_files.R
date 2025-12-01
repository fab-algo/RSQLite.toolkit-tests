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




## ------------------------------------------
table_name <- "INCOME_TAX_BY_MUNICIPALITY"

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

