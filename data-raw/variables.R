library(tidyverse)

# Download data dictionary to get link to detailed variable description
ukb_variables <- readr::read_tsv("https://biobank.ndph.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.tsv") %>%
    select(id = FieldID, ukb_variable_description = Field, link = Link) %>%
    mutate(id = glue::glue("p{id}"))

# Download this file from the specific RAP Project
rap_variables <- readr::read_csv(here::here("data-raw/rap-variables.csv")) %>%
    mutate(id = stringr::str_extract(field_id, "^p[:digit:]+")) %>%
    relocate(id)

project_variables <- rap_variables %>%
    distinct(id) %>%
    left_join(ukb_variables, by = "id")

usethis::use_data(rap_variables, project_variables, overwrite = TRUE, version = 3, internal = TRUE)
usethis::use_data(rap_variables, project_variables, overwrite = TRUE, version = 3)
