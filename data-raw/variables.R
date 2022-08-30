library(tidyverse)

# Download data dictionary to get variables, links, and detailed variable description
ukb_variables <-
    read_tsv(
        "https://biobank.ndph.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.tsv",
        col_types = cols_only(
            FieldID = col_double(),
            Field = col_character(),
            Participants = col_double(),
            Instances = col_double(),
            Array = col_double(),
            Link = col_character()
        )
    ) %>%
    rename_with(snakecase::to_snake_case)

# Convert into a format that RAP can understand. First chunking to use furrr
# for parallel processing since it can sometimes take a while.
rap_variables_chunked <- ukb_variables %>%
    # To have first instance/array be 0 (zero), not one (because of RAP setup).
    mutate(across(c(instances, array), ~ . - 1)) %>%
    mutate(
        instanced = instances >= 1,
        arrayed = array >= 1,
        instance_max = instances,
        instance_min = 0,
        array_max = array,
        array_min = 0
    ) %>%
    select(-participants, -link, -array, -instances) %>%
    pivot_longer(
        cols = -c(field_id, field, instanced, arrayed),
        names_to = c(".value", "range"),
        names_pattern = "^(.*)_(.*)$"
    ) %>%
    select(-range) %>%
    group_split(field_id, field, instanced, arrayed)

create_rap_specific_variables_and_ids <- function(data) {
    data %>%
        tidyr::complete(
            instance = tidyr::full_seq(instance, 1),
            array = tidyr::full_seq(array, 1)
        ) %>%
        tidyr::fill(field_id, field, instanced, arrayed) %>%
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
            field = dplyr::case_when(
                instanced &
                    arrayed ~ glue::glue("{field} | Instance {instance} | Array {array}"),
                instanced &
                    !arrayed ~ glue::glue("{field} | Instance {instance}"),
                !instanced &
                    arrayed ~ glue::glue("{field} | Array {array}"),
                !instanced &
                    !arrayed ~ glue::glue("{field}")
            )
        ) %>%
        dplyr::ungroup() %>%
        dplyr::distinct(field_id, field,)
}

library(furrr)
plan(multisession)
rap_variables <- future_map_dfr(rap_variables_chunked,
                                create_rap_specific_variables_and_ids)
plan(sequential)

project_variables <- ukb_variables %>%
    select(id = field_id,
           ukb_variable_description = field,
           sample_size = participants,
           link) %>%
    mutate(id = glue::glue("p{id}")) %>%
    distinct(id)

usethis::use_data(rap_variables, project_variables, overwrite = TRUE, version = 3, internal = TRUE)
usethis::use_data(rap_variables, project_variables, overwrite = TRUE, version = 3)
