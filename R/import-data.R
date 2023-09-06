
#' Downloads your UKB CSV data file to the `data/data.csv` folder.
#'
#' Use this function every time you open a new RStudio Session, aka every time you
#' use the UKB RAP. We don't want to save the data within the Git repository, so
#' you'd need to download it every time you go back to analyzing the data.
#'
#' @param username A RAP username. Defaults to using `get_username()`.
#' @inheritParams create_csv_from_database
#'
#' @return Downloads CSV to `data/data.csv`.
#' @export
#'
download_project_data <- function(project_id = get_rap_project_id(), username = get_username()) {
  download_command <- glue::glue("dx download /users/{username}/data-{project_id}.csv --output data/data.csv")
  cli::cli_alert_info("Downloading data to {.val data/data.csv}.")
  system(download_command)
  cli::cli_alert_success("Downloaded CSV!")
  return(here::here("data/data.csv"))
}

upload_csv_as_parquet <- function(csv_path, project_id = get_rap_project_id(), username = get_username()) {
  parquet_path <- parquetize::csv_to_parquet(
    path_to_file = csv_path,
    path_to_parquet = fs::path_ext_set(csv_path, ".parquet")
  )

  upload_command <- glue::glue("dx upload {parquet_path} --destination /users/{username}/data-{project_id}.parquet")
  cli::cli_alert_info("Uploaded data to {.val }.")
  system(download_command)
  cli::cli_alert_success("Downloaded CSV!")
  return(here::here("data/data.csv"))
}
