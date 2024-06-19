
#' Downloads your UKB data file to the `data/data.csv` folder.
#'
#' @description
#'
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

#' Read a Parquet file and convert to DuckDB format.
#'
#' @param path Path to the Parquet file.
#'
#' @return A SQL database object.
# read_parquet <- function(path) {
#
#   data <- path %>%
#     arrow::open_dataset()
#
#
#   %>%
#     arrow::to_duckdb()
# }
