library(tidyverse)

# This creates a file that will serve as the basis for selecting the variables.
variables <- readr::read_tsv("https://biobank.ndph.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.tsv")
variables <- variables %>%
    rename_with(snakecase::to_snake_case) %>%
    select(field_id, variable_name = field, link) %>%
    mutate(field_id = glue::glue("p{field_id}"))

usethis::use_data(variables, overwrite = TRUE)
