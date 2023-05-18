library(tidyverse)

# Download data dictionary to get variables, links, and detailed variable description
# List of schemas are here: https://biobank.ndph.ox.ac.uk/ukb/download.cgi
# This schema is from here: https://biobank.ndph.ox.ac.uk/ukb/schema.cgi?id=1
ukb_variables <-
    read_tsv(
        "https://biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=1",
        col_types = cols_only(
            field_id = col_double(),
            title = col_character(),
            num_participants = col_double(),
            instanced = col_double(),
            arrayed = col_double(),
            instance_min = col_double(),
            instance_max = col_double(),
            array_min = col_double(),
            array_max = col_double()
        )
    )

# Convert into a format that RAP can understand. First chunking to use furrr
# for parallel processing since it can sometimes take a while.
rap_variables_chunked <- ukb_variables %>%
    select(-num_participants) %>%
    mutate(
        array_max = case_when(
            str_detect(title, "Non-cancer illness code, self-reported") ~ 0,
            str_detect(title, "Medication for cholesterol, blood pressure or diabetes") ~ 0,
            str_detect(title, "Medication for cholesterol, blood pressure, diabetes, or take exogenous hormones") ~ 0,
            str_detect(title, "^Qualifications$") ~ 0,
            TRUE ~ array_max),
        arrayed = !(array_min == array_max)
    ) %>%
    pivot_longer(
        cols = -c(field_id, title, instanced, arrayed),
        names_to = c(".value", "range"),
        names_pattern = "^(.*)_(.*)$"
    ) %>%
    select(-range) %>%
    group_split(field_id, title, instanced, arrayed)

create_rap_specific_variables_and_ids <- function(data) {
    data %>%
        tidyr::complete(
            instance = tidyr::full_seq(instance, 1),
            array = tidyr::full_seq(array, 1)
        ) %>%
        tidyr::fill(field_id, title, instanced, arrayed) %>%
        dplyr::mutate(
            field_id = dplyr::case_when(
                instanced &
                    arrayed ~ glue::glue("p{field_id}_i{instance}_a{array}"),
                instanced &
                    !arrayed ~ glue::glue("p{field_id}_i{instance}"),
                !instanced &
                    arrayed ~ glue::glue("p{field_id}_a{array}"),
                !instanced &
                    !arrayed ~ glue::glue("p{field_id}")
            ),
            title = dplyr::case_when(
                instanced &
                    arrayed ~ glue::glue("{title} | Instance {instance} | Array {array}"),
                instanced &
                    !arrayed ~ glue::glue("{title} | Instance {instance}"),
                !instanced &
                    arrayed ~ glue::glue("{title} | Array {array}"),
                !instanced &
                    !arrayed ~ glue::glue("{title}")
            )
        ) %>%
        dplyr::ungroup() %>%
        dplyr::distinct(field_id, title)
}

library(furrr)
plan(multisession)
rap_variables <- future_map_dfr(rap_variables_chunked,
                                create_rap_specific_variables_and_ids) %>%
    rename(rap_variable_name = title)
plan(sequential)

# Include a dataframe of variables that are NOT in the very long format.
project_variables <- ukb_variables %>%
    select(id = field_id,
           ukb_variable_description = title,
           number_participants = num_participants) %>%
    mutate(
        link = glue::glue("https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id={id}"),
        id = glue::glue("p{id}")
    ) %>%
    distinct()

usethis::use_data(rap_variables, project_variables, overwrite = TRUE, version = 3, internal = TRUE)
usethis::use_data(rap_variables, project_variables, overwrite = TRUE, version = 3)
