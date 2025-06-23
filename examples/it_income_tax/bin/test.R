data_path <- "../RSQLite.toolkit-tests/data/src"
db_path <- "../RSQLite.toolkit-tests/data/sqlite"


in_files <- dir(path = file.path(data_path, "IT_INCOME_TAX_BY_MUNICIPALITY"),
                pattern = ".*base_comunale_CSV_[0-9]{4}\\.csv")

f_encodings <- c(rep("ISO_8859-1", times=6), 
                 rep("US-ASCII", times=18))

ii<-21
data_file <- file.path(data_path, "IT_INCOME_TAX_BY_MUNICIPALITY",
                       in_files[ii])

fschema <- file_schema_dsv(input_file=data_file,
                           header=TRUE, sep=";", dec=",", grp=".",
                           null_columns=TRUE,
                           force_num_cols=TRUE,
                           comment.char="",
                           quote="", na.strings="",
                           fileEncoding=f_encodings[ii])


input_file <- data_file
header <- TRUE
sep <- ";"
dec <- ","
grp <- ""
max_lines <- 300                         
id_quote_method <- "DB_NAMES"

lpar <- list(
    skip = 0,
    quote = "",
    na.strings = "",
    comment.char = "",
    fill = TRUE,
    fileEncoding = "US-ASCII")






fcon <- file(input_file, "r", blocking = FALSE)
raw_names <- scan(file = fcon,
                  nlines = 1,
                  sep = sep,
                  what = "character",
                  fill = TRUE,
                  multi.line = FALSE,
                  strip.white = TRUE,
                  quiet = TRUE,
                  quote = quote,
                  na.strings = na.strings,
                  comment.char = comment.char,
                  fileEncoding = f_encodings[ii]
                  )
close(fcon)

if (header) {
    src_names <- raw_names    
} else {
    src_names <- paste0("V", 1:length(raw_names))
}

col_classes <- rep("character", length(src_names))

if (is.na(tail(src_names,1)) || tail(src_names,1) == "") {
    src_names <- c(src_names[-length(src_names)], "SKIP")
    col_classes <- c(rep("character", length(src_names)-1), "NULL")    
}

col_names <- format_column_names(x = src_names,
                                 unique_names = TRUE)

df <- utils::read.table(
                 file = input_file,
                 header = header,
                 sep = sep,
                 dec = dec,
                 nrows = max_lines,
                 stringsAsFactors = FALSE,
                 comment.char = comment.char,
                 row.names = NULL,
                 col.names  = col_names,
                 colClasses = col_classes,
                 quote = quote,
                 na.strings = na.strings,
                 fileEncoding = f_encodings[ii]
             )

    
    col_types <- vapply(df, function(col) class(col)[1], character(1))





gg <- function (y, ...) {
    lpar <- eval(substitute(alist(...)))

    if (!("from" %in% names(lpar))) {
        lpar$from <- "latin1"
        from <- "latin1"
    } else {
        from <- lpar$from
    }

    if (from == "ASCII")
        print(from)

    lpar1 <- append(x=lpar, values=list(x=y), after=0)
    print(lpar1)

    do.call(iconv, lpar1)
}





