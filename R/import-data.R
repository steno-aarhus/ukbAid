
#' Downloads your UKB data file to the `data/data.csv` folder.
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
                          username = get_username()) {
  file_ext <- rlang::arg_match(file_ext)
  rap_data_path <- glue::glue("/users/{username}/{file_prefix}-{project_id}.{file_ext}")
  output_path <- glue::glue("data/data.{file_ext}")
  download_command <- glue::glue("dx download {rap_data_path} --output {output_path}")
  cli::cli_alert_info("Downloading data to {.val {output_path}}.")
  system(download_command)
  cli::cli_alert_success("Downloaded the data file!")
  return(here::here(output_path))
}

#' Upload a data file to the RAP.
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
                        username = get_username()) {
  rap_path <- glue::glue("/users/{username}/{file_prefix}-{project_id}.{fs::path_ext(path)}")
  upload_command <- glue::glue("dx upload {path} --destination {rap_path}")
  cli::cli_alert_info("Uploading data to {.val {rap_path}}.")
  system(download_command)
  cli::cli_alert_success("Uploaded the file to the RAP!")
  return(rap_path)
}

#' Read a Parquet file and convert to DuckDB format.
#'
#' @param path Path to the Parquet file.
#'
#' @return A SQL database object.
#' @export
#'
read_parquet <- function(path) {
  path %>%
    arrow::open_dataset() %>%
    arrow::to_duckdb()
}
