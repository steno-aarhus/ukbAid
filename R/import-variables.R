#' @title
#' (For admin) Import and process the `field.tsv` file before uploading to UKB RAP home folder.
#'
#' @description
#' This function imports the `field.tsv` file in the `Showcase metadata` folder
#' and then processes it so that the variable names and field IDs match what is
#' found in the "Cohort Browser" (because annoyingly they don't match). Lastly,
#' the processed metadata gets saved back to the RAP Project folder so other
#' researchers on the Project can use it to select (and eventually download) the
#' variables and data they need for their analysis. The purpose of this function
#' is to create this shared `database-variables.csv` file so that, when used in
#' conjunction with the [read_ukb_database()] function, the variable selection
#' and data creation can be reproduced easily. Small note, the `schema.tsv` file
#' in the metadata folder briefly describes what each TSV file contains.
#'
#' @return Saves a CSV file in the main RAP Project folder.
#' @export
#'
import_clean_and_upload_database_variables <- function() {
    utils::read.delim("/mnt/project/Showcase metadata/field.tsv") %>%
        tibble::as_tibble() %>%
        dplyr::select(field_id,
                      variable_name = title,
                      contains("instance"),
                      contains("array"),
                      -instance_id) %>%
        dplyr::mutate(instanced = instanced >= 1, arrayed = arrayed >= 1) %>%
        tidyr::pivot_longer(
            cols = -c(field_id, variable_name, instanced, arrayed),
            names_to = c(".value", "range"),
            names_pattern = "^(.*)_(.*)$"
        ) %>%
        dplyr::select(-range) %>%
        dplyr::group_by(field_id, variable_name, instanced, arrayed) %>%
        tidyr::complete(instance = tidyr::full_seq(instance, 1),
                        array = tidyr::full_seq(array, 1)) %>%
        dplyr::mutate(
            field_id = dplyr::case_when(
                instanced & arrayed ~ glue::glue("p{field_id}_i{instance}_a{array}"),
                instanced & !arrayed ~ glue::glue("p{field_id}_i{instance}"),
                !instanced & arrayed ~ glue::glue("p{field_id}_a{array}"),
                !instanced & !arrayed ~ glue::glue("p{field_id}")
            ),
            variable_name = dplyr::case_when(
                instanced & arrayed ~ glue::glue("{variable_name} | Instance {instance} | Array {array}"),
                instanced & !arrayed ~ glue::glue("{variable_name} | Instance {instance}"),
                !instanced & arrayed ~ glue::glue("{variable_name} | Array {array}"),
                !instanced & !arrayed ~ glue::glue("{variable_name}")
            )
        ) %>%
        dplyr::ungroup() %>%
        dplyr::distinct(field_id, variable_name) %>%
        readr::write_csv(file = "database-variables.csv")

        upload_success <- system("dx upload database-variables.csv", intern = TRUE)
        return(upload_success)
}

#' Take the selected UKB variables from the protocol stage and subset the RAP specific variables list.
#'
#' This is done because RAP has a special naming system for their variables inside
#' the UK Biobank dataset that is slightly different from how the UK Biobank names them.
#'
#' @param project_variables_file The file location for the project variable CSV file. Defaults to `data-raw/project-variables.csv`.
#' @param rap_variables_file The file location for the RAP specific variable CSV file. Defaults to `data-raw/rap-variables.csv`.
#' @param instances An "instance" in UK Biobank is a time point of collection
#'   for the variable. So a variable with Instance 0 and Instance 1 means that
#'   the variable was collected twice at two different times. The default is to
#'   select all the time points. Max is 9 instances, and while many variables
#'   have up to 4 instances, the majority only have one (e.g. 0).
#' @param save Whether to save (and overwrite) the newly subsetted RAP variables.
#'
#' @return A tibble of the newly subsetted RAP variable list. Save (overwrite) original RAP csv file.
#' @export
#'
subset_rap_variables <- function(project_variables_file = "data-raw/project-variables.csv",
                                 rap_variables_file = "data-raw/rap-variables.csv", instances = 0:9, save = TRUE) {
    instance_pattern <- glue::glue("Instance [{min(instances)}-{max(instances)}]")
    proj_vars <- readr::read_csv(here::here(project_variables_file), show_col_types = FALSE) %>%
        dplyr::select(id)
    rap_vars <- readr::read_csv(here::here(rap_variables_file), show_col_types = FALSE) %>%
        dplyr::filter(stringr::str_detect(rap_variable_name, instance_pattern) |
                          # To keep also variables like Sex that don't have instances
                          stringr::str_detect(rap_variable_name, " \\| Instance", negate = TRUE))

    new_rap_vars <- rap_vars %>%
        dplyr::mutate(id = stringr::str_extract(field_id, "^p[:digit:]+")) %>%
        dplyr::right_join(proj_vars, by = "id")

    if (save) {
        cli::cli_alert_info("Updated the {.val {rap_variables_file}} based on the selected project variables.")
        readr::write_csv(new_rap_vars, here::here(rap_variables_file))
    }

    return(new_rap_vars)
}
