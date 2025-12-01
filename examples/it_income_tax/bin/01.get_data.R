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


