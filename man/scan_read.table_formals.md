
|------------------|-------------------|------------------------------|
|                  | utils::read.table | base::scan                   |
|------------------|-------------------|------------------------------|
| file             |                   | ""                           |
| text             |                   |                              |
|------------------|-------------------|------------------------------|
| skip             | 0                 | 0                            |
|                  |                   |                              |
| sep              | ""                | ""                           |
| dec              | "."               | "."                          |
| quote            | "\"'"             | if (identical(sep, "\n")) "" |
|                  |                   | else "'\""                   |
| na.strings       | "NA"              | "NA"                         |
| comment.char     | "#"               | ""                           |
|                  |                   |                              |
| allowEscapes     | FALSE             | FALSE                        |
| strip.white      | FALSE             | FALSE                        |
| fill             | !blank.lines.skip | FALSE                        |
| blank.lines.skip | TRUE              | TRUE                         |
| flush            | FALSE             | FALSE                        |
| skipNul          | FALSE             | FALSE                        |
| fileEncoding     | ""                | ""                           |
| encoding         | "unknown"         | "unknown"                    |
|                  |                   |                              |
|                  |                   |                              |
|------------------|-------------------|------------------------------|
| nrows            | -1                |                              |
| header           | FALSE             |                              |
| check.names      | TRUE              |                              |
| col.names        |                   |                              |
| colClasses       | NA                |                              |
| row.names        |                   |                              |
| as.is            | !stringsAsFactors |                              |
| stringsAsFactors | FALSE             |                              |
| tryLogical       | TRUE              |                              |
|                  |                   |                              |
| numerals         | c("allow.loss",   |                              |
|                  | "warn.loss",      |                              |
|                  | "no.loss")        |                              |
|                  |                   |                              |
|                  |                   |                              |
|------------------|-------------------|------------------------------|
| nlines           |                   | 0                            |
| multi.line       |                   | TRUE                         |
| what             |                   | double()                     |
| nmax             |                   | -1L                          |
| n                |                   | -1L                          |
| quiet            |                   | FALSE                        |
|------------------|-------------------|------------------------------|
|                  |                   |                              |



common
```
 [1] "file"             "sep"              "quote"            "dec"
 [5] "na.strings"       "skip"             "fill"             "strip.white"
 [9] "blank.lines.skip" "comment.char"     "allowEscapes"     "flush"
[13] "fileEncoding"     "encoding"         "text"             "skipNul"
```

read.table
```
 [1] "header"           "numerals"         "row.names"        "col.names"
 [5] "as.is"            "tryLogical"       "colClasses"       "nrows"
 [9] "check.names"      "stringsAsFactors"
```

scan
```
 [1] "what"       "nmax"       "n"          "nlines"     "quiet"      "multi.line"
```




