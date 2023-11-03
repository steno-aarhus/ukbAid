dare_project_record_id <- "record-GXZ2k40JbxZx7xYGF66y45Yq"

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
#'   `data-raw/rap-variables.csv` file, open that file, and delete all variables you
#'   don't want to keep. This is the file that contains the `variable_name` column
#'   you would use for this argument.
#' @param dataset_record_id The "record ID" of the database, found when clicking
#'   the `.dataset` file in the RAP project folder. Defaults to the ID for the
#'   Steno project `dare_project_record_id`.
#' @param project_id The project's abbreviation. Defaults to using
#'   `get_rap_project_id()`, which is the name of the project folder.
#' @param username The username to set where the dataset is saved to. Defaults to using
#'   `get_username()`, which is the name of the current user of the session.
#' @param file_prefix The prefix to add to the start of the file name. Defaults to "data".
#'
#' @return Outputs whether the extraction and creation of the data was
#'   successful or not. Used for the side effect of creating the CSV on the RAP
#'   server. The newly created CSV will have your username in the filename.
#' @export
#'
#' @examples
#' \dontrun{
#' library(tidyverse)
#' read_csv("data-raw/rap-variables.csv") %>%
#'   pull(variable_name) %>%
#'   create_csv_from_database()
#' # rap_variables %>%
#' #   pull(field_id) %>%
#' #   create_csv_from_database(project_id = "mesh", username = "lwjohnst")
#' }
create_csv_from_database <- function(variables_to_extract, field = c("name", "title"),
                                     file_prefix = "data",
                                     project_id = get_rap_project_id(),
                                     dataset_record_id = dare_project_record_id,
                                     username = get_username()) {
  table_exporter_command <- builder_table_exporter(
    variables_to_extract = variables_to_extract,
    field = field,
    file_prefix = file_prefix,
    project_id = project_id,
    dataset_record_id = dare_project_record_id,
    username = username
  )

  cli::cli_alert_info("Started extracting the variables and converting to CSV.")
  cli::cli_alert_warning("This function runs for quite a while, at least 5 minutes or more. Please be patient to let it finish.")
  table_exporter_results <- system(table_exporter_command, intern = TRUE)
  system(glue::glue("dx mv {data_file_name}.csv /users/{username}/{file_prefix}-{project_id}.csv"))
  user_path <- glue::glue("/mnt/project/users/{username}")
  cli::cli_alert_success("Finished saving to CSV. Check {.val {user_path}} or the project folder on the RAP to see that it was created.")
  relevant_results <- tail(table_exporter_results, 3)[1:2]
  return(relevant_results)
}

#' Build, but not run, the dx table exporter command.
#'
#' This is mostly for testing purposes.
#'
#' @inheritParams create_csv_from_database
#'
#' @return Outputs character string of command sent to `dx`.
#'
#' @examples
#' library(tibble)
#' library(dplyr)
#' library(stringr)
#' library(magrittr)
#' rap_variables %>%
#'   filter(str_detect(rap_variable_name, "\'")) %>%
#'   sample_n(10) %>%
#'   pull(rap_variable_name) %>%
#'   builder_table_exporter(project_id = "test", username = "lwj") %>%
#'   cat()
builder_table_exporter <- function(variables_to_extract, field = c("name", "title"),
                                   file_prefix = "data",
                                   project_id = get_rap_project_id(),
                                   dataset_record_id = dare_project_record_id,
                                   username = get_username()) {
  stopifnot(is.character(dataset_record_id), is.character(variables_to_extract))
  field <- rlang::arg_match(field)
  field <- switch(
    field,
    title = "ifield_titles",
    name = "ifield_names"
  )

  # Need to escape the ' because of issue with dx
  variables_to_extract <- stringr::str_replace_all(
    variables_to_extract,
    "'",
    "\\\\'"
  )

  fields_to_get <- paste0(glue::glue("-{field}='{variables_to_extract}'"), collapse = " ")
  data_file_name <- glue::glue("data-{username}-{project_id}")
  glue::glue(
    paste0(
      c(
        "dx run app-table-exporter --brief --wait -y",
        "-idataset_or_cohort_or_dashboard={dataset_record_id}",
        "{fields_to_get}",
        "-ioutput={data_file_name}"
      ),
      collapse = " "
    )
  )
}

#' Get the RAP project ID, will be the project main folder.
#'
#' @return The project abbreviation/id, which is the name of the project folder
#'   (and the same as the name of the `.Rproj` folder).
#' @export
#'
get_rap_project_id <- function() {
  options(usethis.quiet = TRUE)
  on.exit(options(usethis.quiet = NULL))
  fs::path_file(usethis::proj_path())
}

#' Get the username of the user's who started the RStudio session.
#'
#' @return Character vector with users username within the RAP session.
#' @export
#'
get_username <- function() {
  system("dx whoami", intern = TRUE)
}
