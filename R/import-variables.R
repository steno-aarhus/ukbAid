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

#' Downloads the CSV file with the list of database variables and saves to `data-raw/rap-variables.csv`.
#'
#' You would run this function when you just start your project, in order to have
#' a list of variables you want to use in your data analysis. You usually don't
#' need to do this more than once, unless you made a mistake in the file.
#' After downloading the variable list to `data-raw/rap-variables.csv`, you'd then
#' Git commit the downloaded file and afterwards would open it and remove
#' any variable you won't need.
#'
#' @return Doesn't return anything. Used for the side effect of downloading the data.
#' @export
#'
download_database_variables <- function() {
    cli::cli_alert_info("Downloading {.val database-variables.csv} to {.val data-raw/rap-variables.csv}.")
    system("dx download database-variables.csv --output data-raw/rap-variables.csv", intern = TRUE)
    cli::cli_alert_success("Downloaded!")
    return(invisible())
}

#' Commit the database variables to Git.
#'
#' @return Nothing. Adds and commits the `rap-variables.csv` file to Git.
#' @export
#'
git_commit_database_variables <- function() {
    gert::git_add(files = here::here("data-raw/rap-variables.csv"))
    gert::git_commit("Added the variable list from the main RAP project into data-raw.")
    cli::cli_alert_success("Committed rap variable list to Git.")
    return(invisible())
}

#' Take the selected UKB variables from the protocol stage and subset the RAP specific variables list.
#'
#' This is done because RAP has a special naming system for their variables inside
#' the UK Biobank dataset that is slightly different from how the UK Biobank names them.
#'
#' @param project_variables_file The file location for the project variable CSV file. Defaults to `data-raw/project-variables.csv`.
#' @param rap_variables_file The file location for the RAP specific variable CSV file. Defaults to `data-raw/rap-variables.csv`.
#' @param save Whether to save (and overwrite) the newly subsetted RAP variables.
#'
#' @return A tibble of the newly subsetted RAP variable list. Save (overwrite) original RAP csv file.
#' @export
#'
subset_rap_variables <- function(project_variables_file = "data-raw/project-variables.csv",
                                 rap_variables_file = "data-raw/rap-variables.csv", save = TRUE) {
    proj_vars <- readr::read_csv(here::here(project_variables_file), show_col_types = FALSE) %>%
        dplyr::mutate(id = field_id)
    rap_vars <- readr::read_csv(here::here(rap_variables_file), show_col_types = FALSE)

    new_rap_vars <- rap_vars %>%
        dplyr::mutate(id = stringr::str_extract(field_id, "^p[:digit:]+")) %>%
        dplyr::right_join(proj_vars, by = "id") %>%
        dplyr::select(-id)

    if (save) {
        readr::write_csv(here::here(rap_variables_file))
    }

    return(new_rap_vars)
}
