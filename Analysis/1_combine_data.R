## Code to combine all datasets into one big corre dataframe
## AC 231101

## Data manipulation packages
library(tidyverse)
source("utilities/data_import.R")

## Data import
# https://drive.google.com/file/d/1s6-MzHC74A-GUqQYa4VB5eVFGEw-DEVd/view?usp=sharing
corre <- read_csv_gdrive("1s6-MzHC74A-GUqQYa4VB5eVFGEw-DEVd")%>%
  as_tibble()
cdr_corre <- read.csv("data_corre/cdr_corre.csv", row.names = 1)
sier_corre <- read.csv("data_corre/sier_corre.csv", row.names = 1)


## Combine datasets
sier_corre$plot_id <- as.character(sier_corre$plot_id)
sier_corre$community_type <- as.character(sier_corre$community_type)
sier_corre$block <- as.character(sier_corre$block)

cdr_corre$plot_id <- as.character(cdr_corre$plot_id)
cdr_corre$community_type <- as.character(cdr_corre$community_type)
cdr_corre$block <- as.character(cdr_corre$block)

corre_all <- corre %>% add_row(cdr_corre)
corre_all <- corre_all %>% add_row(sier_corre)

## Write out and put back on g drive
write.csv(corre_all, "data_corre/corre_all.csv")
