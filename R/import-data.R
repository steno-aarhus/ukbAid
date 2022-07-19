dare_project_record_id <- "record-G9zGPB0JbxZz4xPy60PBPk1Z"

#' Extract variables you want from the UKB database and create a CSV file to later upload to your own project.
#'
#' This function tells RAP to extract the variables you want from the `.dataset`
#' database file and to create a CSV file within the main RAP project folder.
#' When you want to use the CSV file in your own data analysis project, use
#' `download_project_data()`. You probably don't need to run this function often,
#' probably only once at the start of your project. NOTE: This function takes
#' 5 minutes to run on the UKB RAP, so be careful with just randomly running it.
#'
#' @param variables_to_extract A character vector of variables you want to
#'   extract from the UKB database (from the `.dataset` file). Use
#'   `save_database_variables_to_project()` to create the
#'   `data-raw/variables.csv` file, open that file, and delete all variables you
#'   don't want to keep. This is the file that contains the `variable_name` column
#'   you would use for this argument.
#' @param dataset_record_id The "record ID" of the database, found when clicking
#'   the `.dataset` file in the RAP project folder. Defaults to the ID for the
#'   Steno project `dare_project_record_id`.
#'
#' @return Outputs whether the extraction and creation of the data was
#'   successful or not. Used for the side effect of creating the CSV on the RAP
#'   server. The newly created CSV will have your username in the filename.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' library(tidyverse)
#' read_csv("data-raw/variables.csv") %>%
#'   pull(variable_name) %>%
#'   create_csv_from_database()
#' }
create_csv_from_database <- function(variables_to_extract, dataset_record_id = dare_project_record_id) {
    stopifnot(is.character(dataset_record_id), is.character(variables_to_extract))

    table_exporter_options <- list(
        dataset_or_cohort_or_dashboard = list(`$dnanexus_link` = dataset_record_id),
        field_titles = variables_to_extract,
        header_style = "FIELD-TITLE"
    )

    user_name <- system("dx whoami", intern = TRUE)
    table_exporter_options <- rjson::toJSON(table_exporter_options)
    table_exporter_command <- glue::glue(
        "dx run app-table-exporter -ientity=participant --brief --wait -y -j '{table_exporter_options}' -ioutput=data-{user_name}"
    )
    cli::cli_alert_info("Started extracting the variables and converting to CSV.")
    table_exporter_results <- system(table_exporter_command, intern = TRUE)
    cli::cli_alert_success("Finished saving to CSV. Check {.val /mnt/project/} or the project folder on the RAP to see that it was created.")
    relevant_results <- tail(table_exporter_results, 3)[1:2]
    return(relevant_results)
}

#' Get the username of the user's who started the RStudio session.
#'
#' @return Character vector with users username within the RAP session.
#' @export
#'
get_username <- function() {
    system("dx whoami", intern = TRUE)
}

#' Downloads your UKB CSV data file to the `data/data.csv` folder.
#'
#' Use this function every time you open a new RStudio Session, aka every time you
#' use the UKB RAP. We don't want to save the data within the Git repository, so
#' you'd need to download it every time you go back to analyzing the data.
#'
#' @param username A RAP username. Defaults to using `get_username()`.
#'
#' @return Downloads CSV to `data/data.csv`.
#' @export
#'
download_project_data <- function(username = get_username()) {
    download_command <- glue::glue("dx download data-{username}.csv --output data/data.csv")
    cli::cli_alert_info("Downloading data to {.val data/data.csv}.")
    system(download_command)
    cli::cli_alert_success("Downloaded CSV!")
    return(invisible())
}
