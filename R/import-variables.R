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

#' Downloads the CSV file with the list of database variables and saves to `data-raw/variables.csv`.
#'
#' You would run this function when you just start your project, in order to have
#' a list of variables you want to use in your data analysis. You usually don't
#' need to do this more than once, unless you made a mistake in the file.
#' After downloading the variable list to `data-raw/variables.csv`, you'd then
#' Git commit the downloaded file and afterwards would open it and remove
#' any variable you won't need.
#'
#' @return Doesn't return anything. Used for the side effect of downloading the data.
#' @export
#'
download_database_variables <- function() {
    cli::cli_alert_info("Downloading {.val database-variables.csv} to {.val data-raw/variables.csv}.")
    system("dx download database-variables.csv --output data-raw/variables.csv", intern = TRUE)
    cli::cli_alert_success("Downloaded!")
    return(invisible())
}
