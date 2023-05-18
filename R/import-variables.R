
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
