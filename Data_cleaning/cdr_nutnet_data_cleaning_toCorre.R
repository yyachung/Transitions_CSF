### CDR Nut Net Data Cleaning ###

## Data manipulation packages
library(tidyverse)
source("utilities/data_import.R")

## Data import
# 1e9kxlsVHiBxw3s7bqY1c3GtNWoWSFA9U
cdr_nutnet <- read_csv_gdrive("1e9kxlsVHiBxw3s7bqY1c3GtNWoWSFA9U")%>%
  as_tibble()

## Working data frame
cdr <- cdr_nutnet

## Calculate anpp by summing legume, forbs, and graminoids
## Use only treatments included in CoRRE database
## Calculate only for previously unincluded years
cdr_anpp <- cdr_nutnet %>%
  filter(category %in% c("FORB","GRAMINOID","LEGUME") ) %>%
  filter(trt %in% c("Control","NP","N", "P")) %>%
  filter(year > 2020) %>% #Pre-2020 data already in corre
  group_by(plot, year, trt) %>%
  summarise(anpp = sum(mass))

# make trt_type variable
trt.dat<-data.frame(trt = c("Control", "N", "P", "NP"),
                    trt_type = c("control", "N", "P", "N*P"))
cdr_anpp <- left_join(cdr_anpp, trt.dat, by = "trt") 

# make n p  variables
np.dat <- data.frame(trt = c("Control", "N", "P", "NP"),
                      n = c(0, 10, 0, 10),
                      p = c(0, 0, 10, 10))
cdr_anpp <- left_join(cdr_anpp, np.dat, by = "trt") 

## Reformat to CoRRE
cdr_corre <- cdr_anpp %>%
  ## format column names to match the rest of the datasets
  dplyr::mutate(site_code = "CDR",
                project_name = "NutNet",
                treatment_year = year-2007,
                calendar_year = year,
                treatment = trt,
                plot_id = plot, 
                anpp = anpp, 
                community_type = "0",
                block = "0",
                public = "0",
                trt_type = trt_type,
                n = n,
                p = p, 
                k = "0",
                precip = "0",
                successional = "0",
                pulse = "0",
                plant_mani = "0") 
cdr_corre <- cdr_corre[, -c(1:3)]

write.csv(cdr_corre, "data_corre/cdr_corre.csv")
