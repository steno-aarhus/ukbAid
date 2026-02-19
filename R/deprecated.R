#' Downloads your UKB data file to the `data/data.csv` folder.
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Use this function every time you open a new RStudio Session, aka every time you
#' use the UKB RAP. We don't want to save the data within the Git repository, so
#' you'd need to download it every time you go back to analyzing the data.
#'
#' @param file_ext The file extension of the dataset. Defaults to "csv", but can also provide "parquet".
#' @inheritParams create_csv_from_database
#'
#' @return Downloads the data file to `data/`.
#' @export
#'
download_data <- function(project_id = get_rap_project_id(),
                          file_prefix = "data",
                          file_ext = c("csv", "parquet"),
                          username = rap_get_user()) {
  lifecycle::deprecate_soft(
    when = "0.1.0",
    what = "download_data()",
    with = "rap_copy_from()"
  )
  file_ext <- rlang::arg_match(file_ext)
  rap_file <- rap_get_path_user_files(username) |>
    stringr::str_subset(file_ext) |>
    stringr::str_sort(decreasing = TRUE) |>
    head(1)
  rap_path <- glue::glue("/users/{username}/{rap_file}")

  cli::cli_alert_info("Downloading from RAP: {.val {rap_path}}.")
  output_path <- glue::glue("data/data.{file_ext}")
  cli::cli_alert_info("Downloading data to {.val {output_path}}.")
  rap_copy_from(rap_path, output_path)
  cli::cli_alert_success("Downloaded the data file!")
  return(output_path)
}

#' Upload a data file to the RAP.
#'
#' `r lifecycle::badge("deprecated")`
#'
#' @param path Path to the dataset you want to upload.
#' @inheritParams create_csv_from_database
#'
#' @return A path to the uploaded data file.
#' @export
#'
upload_data <- function(path,
                        project_id = get_rap_project_id(),
                        file_prefix = "data",
                        username = rap_get_user()) {
  lifecycle::deprecate_stop(
    when = "0.1.0",
    what = "upload_data()",
    with = "rap_copy_to()"
  )
}

#' Take the selected UKB variables from the protocol stage and subset the RAP specific variables list.
#'
#' @description
#' `r lifecycle::badge("deprecated")`
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
  lifecycle::deprecate_warn(
    when = "0.1.0",
    what = "subset_rap_variables()",
    details = "This function is no longer recommended to use. See using `proj_create_dataset()` instead."
  )
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

dare_project_record_id <- "record-GXZ2k40JbxZx7xYGF66y45Yq"

#' Extract variables you want from the UKB database and create a CSV file to later upload to your own project.
#'
#' @description
#' `r lifecycle::badge("deprecated")`
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
#'   `rap_get_user()`, which is the name of the current user of the session.
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
#' rap_variables %>%
#'   pull(id) %>%
#'   create_csv_from_database(project_id = "mesh", username = "lwjohnst")
#' }
create_csv_from_database <- function(variables_to_extract, field = c("name", "title"),
                                     file_prefix = "data",
                                     project_id = get_rap_project_id(),
                                     dataset_record_id = dare_project_record_id,
                                     username = rap_get_user()) {
  lifecycle::deprecate_soft(
    when = "0.1.0",
    what = "create_csv_from_database()",
    with = "proj_create_dataset()"
  )
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
  data_path <- rap_get_path_files(".") |>
    stringr::str_subset("\\.csv$") |>
    stringr::str_subset(username) |>
    stringr::str_subset(project_id) |>
    stringr::str_sort(decreasing = TRUE) |>
    head(1)

  new_path <- data_path |>
    stringr::str_remove(username)
  system(glue::glue("dx mv {data_path} /users/{username}/{new_path}"))
  cli::cli_alert_success("Finished saving to CSV.")
  relevant_results <- tail(table_exporter_results, 3)[1:2]
  return(relevant_results)
}

timestamp_now <- function() {
  lubridate::now() |>
    lubridate::format_ISO8601() |>
    stringr::str_replace_all("[:]", "-")
}

#' Build, but not run, the dx table exporter command.
#'
#' @description
#' `r lifecycle::badge("deprecated")`
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
#'   sample_n(10) %>%
#'   pull(id) %>%
#'   builder_table_exporter(project_id = "test", username = "lwj") %>%
#'   cat()
builder_table_exporter <- function(variables_to_extract, field = c("name", "title"),
                                   file_prefix = "data",
                                   project_id = get_rap_project_id(),
                                   dataset_record_id = dare_project_record_id,
                                   username = rap_get_user()) {
  stopifnot(is.character(dataset_record_id), is.character(variables_to_extract))
  field <- rlang::arg_match(field)
  field <- switch(field,
    title = "ifield_titles",
    name = "ifield_names"
  )

  # Need to escape the ' because of issue with dx
  variables_to_extract <- stringr::str_replace_all(
    variables_to_extract,
    "('|\\(|\\)|\")",
    "\\\\\\1"
  )

  fields_to_get <- paste0(glue::glue('-{field}="{variables_to_extract}"'), collapse = " ")
  data_file_name <- glue::glue("{username}-data-{project_id}-{timestamp_now()}")
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

#' @describeIn proj_get_name Deprecated function. Use `proj_get_name()` instead.
#' @export
get_rap_project_id <- function() {
  lifecycle::deprecate_soft(
    when = "0.1.0",
    what = "get_rap_project_id()",
    with = "proj_get_name()"
  )
  proj_get_name()
}

#' @describeIn proj_get_dependencies Deprecated function. Use `proj_get_dependencies()` instead.
#' @export
get_proj_dependencies <- function() {
  lifecycle::deprecate_soft(
    when = "0.1.0",
    what = "get_proj_dependencies()",
    with = "proj_get_dependencies()"
  )
  proj_get_dependencies()
}

#' @describeIn proj_setup_rap Deprecated function. Use `proj_setup_rap()` instead.
#' @export
setup_ukb_rap <- function() {
  lifecycle::deprecate_soft(
    when = "0.1.0",
    what = "setup_ukb_rap()",
    with = "proj_setup_rap()"
  )
  proj_setup_rap()
}

#' @describeIn rap_get_user Deprecated function. Use `rap_get_user()` instead.
#' @export
get_username <- function() {
  lifecycle::deprecate_soft(
    when = "0.1.0",
    what = "get_username()",
    with = "rap_get_user()"
  )
  rap_get_user()
}
