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
  # mutate(array_max = 0, array_min = 0) %>%
  mutate(
    instance_max = case_when(
      field_id %in% c(22032, 22033, 22034, 22035, 22036, 22037, 22038, 22039, 22040) ~ 0, # I think this issue encompasses all MET scores in category-id 54, at least p22035 and p22036 which cause errors for me. I have to remove all follow-up instances.
      TRUE ~ instance_max
    ),
    array_max = case_when(
      field_id %in% c(41280, 41281, 41257, 41260, 41262, 41263, 41282, 41283, 41202, 41204) ~ array_max, # added some variables that are arrayed.
      str_detect(title, "Non-cancer illness code, self-reported") ~ 0,
      str_detect(title, "Medication for cholesterol, blood pressure or diabetes") ~ 0,
      str_detect(title, "Medication for cholesterol, blood pressure, diabetes, or take exogenous hormones") ~ 0,
      str_detect(title, "^Qualifications$") ~ 0,
      # TODO: Not sure if array is needed in RAP... Will need to modify this code here.
      # Set all array's max to 0 since we might not need array's, but I'm not sure.
      # TRUE ~ array_max
      TRUE ~ 0 # This causes issues for variables with multiple instances AND arrays, at least p93, p94, p4079, p4079 (blood pressure variables with 2 arrays for each instance), and p40002 (two instances and 15 arrays). I think Jie had issues with other variables as well.
    ),
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
          arrayed ~ glue::glue("p{field_id}_i{instance}_a{array}"), # If arrays aren't removed above, variables with multiple instances and arrays wouldn't cause errors. On the other side, if the code is changed and arrays aren't removed, at lot of people's code may not work when variables change names...
        instanced &
          !arrayed ~ glue::glue("p{field_id}_i{instance}"),
        !instanced &
          arrayed ~ glue::glue("p{field_id}_a{array}"),
        !instanced &
          !arrayed ~ glue::glue("p{field_id}")
      ),
      title = dplyr::case_when(
        instanced &
          arrayed ~ glue::glue("{title} | Instance {instance} | Array {array}"), # This is what I need to do manually right now :D
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
rap_variables <- future_map_dfr(
  rap_variables_chunked,
  create_rap_specific_variables_and_ids
) %>%
  rename(rap_variable_name = title)
plan(sequential)

# Include a dataframe of variables that are NOT in the very long format.
project_variables <- ukb_variables %>%
  select(
    id = field_id,
    ukb_variable_description = title,
    number_participants = num_participants
  ) %>%
  mutate(
    link = glue::glue("https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id={id}"),
    id = glue::glue("p{id}")
  ) %>%
  distinct()

usethis::use_data(rap_variables, project_variables, overwrite = TRUE, version = 3, internal = TRUE)
usethis::use_data(rap_variables, project_variables, overwrite = TRUE, version = 3)

path_database_schema() |>
  dx_get("data-raw/schema.json.gz")

fs::path("data-raw", "schema.json.gz") |>
  R.utils::gunzip()

fields <- jsonlite::read_json("data-raw/schema.json")

names(fields$model$entities$participant$fields)
