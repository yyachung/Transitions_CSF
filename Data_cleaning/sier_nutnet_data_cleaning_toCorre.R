### Sierra Nevada Nut Net Data Cleaning ###

## Data manipulation packages
library(tidyverse)
source("utilities/data_import.R")

## Data import
# https://drive.google.com/file/d/1Cg6JGhwvmbOzChtqGVzMz_TVMYq1JLI7/view?usp=sharing
sier_nutnet <- read_csv_gdrive("1Cg6JGhwvmbOzChtqGVzMz_TVMYq1JLI7")%>%
  as_tibble()

## Working data frame
sier <- sier_nutnet

## Calculate anpp by summing legume, forbs, and graminoids
## Use only treatments included in CoRRE database
## Calculate only for previously unincluded years
sier_anpp <- sier_nutnet %>%
  filter(category %in% c("FORB","GRAMINOID","LEGUME") ) %>%
  filter(trt %in% c("Control","NP","N", "P")) %>%
  filter(year > 2020) %>% #Pre-2020 data already in corre
  group_by(plot, year, trt) %>%
  summarise(anpp = sum(mass))

# make trt_type variable
trt.dat<-data.frame(trt = c("Control", "N", "P", "NP"),
                    trt_type = c("control", "N", "P", "N*P"))
sier_anpp <- left_join(sier_anpp, trt.dat, by = "trt") 

# make n p  variables
np.dat <- data.frame(trt = c("Control", "N", "P", "NP"),
                     n = c(0, 10, 0, 10),
                     p = c(0, 0, 10, 10))
sier_anpp <- left_join(sier_anpp, np.dat, by = "trt") 

## Reformat to CoRRE
sier_corre <- sier_anpp %>%
  ## format column names to match the rest of the datasets
  dplyr::mutate(site_code = "sier.us",
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
sier_corre <- sier_corre[, -c(1:3)]

write.csv(sier_corre, "data_corre/sier_corre.csv")
