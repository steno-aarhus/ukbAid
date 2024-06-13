#' Get the RAP project ID, will be the project main folder.
#'
#' @return The project abbreviation/id, which is the name of the project folder
#'   (and the same as the name of the `.Rproj` folder).
#' @export
#'
proj_get_name <- function() {
  options(usethis.quiet = TRUE)
  on.exit(options(usethis.quiet = NULL))
  fs::path_file(usethis::proj_path())
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

#' Get package dependencies from the DESCRIPTION file.
#'
#' @return A character vector of package names.
#' @export
#'
proj_get_dependencies <- function() {
  desc::desc_get_deps()$package |>
    stringr::str_subset("^R$", negate = TRUE)
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

# proj_get_git_config()
# proj_get_rstudio_config()
# proj_setup_git_config()
# proj_setup_rstudio_config()

#' Create a file name unique for a project and user, along with timestamp.
#'
#' You use this when you want to create a dataset when using [proj_create_database()].
#'
#' @param user The name of the user you are creating this dataset for.
#'
#' @return A character scalar.
#' @export
#'
#' @examples
#' \dontrun{
#' proj_create_path_dataset("lwjohnst")
#' }
proj_create_path_dataset <- function(user) {
  verify_dx()
  user <- rlang::arg_match(
    user,
    rap_get_path_users() |>
      stringr::str_remove("/$") |>
      stringr::str_remove("^/users/")
  )
  project_id <- proj_get_name()
  timestamp_now <- lubridate::now() |>
    lubridate::format_ISO8601() |>
    stringr::str_replace_all("[:]", "-")
  glue::glue("{user}-{project_id}-{timestamp_now()}.csv")
}


#'
#' This function tells RAP to extract the variables you want from the `.dataset`
#' database file and to create a CSV file within the main RAP project folder.
#' When you want to use the CSV file in your own data analysis project, use
#' `download_project_data()`. You probably don't need to run this function often,
#' probably only once at the start of your project. NOTE: This function takes
#' 5-60 minutes to run on the UKB RAP, so be careful with just randomly running it.
#'
#' @param fields A character vector of field IDs you want to extract from the
#'   UKB database. Select the variable ids from the [rap_variables] dataset.
#' @param output_path The name of the output CSV file.
#' @param database_id The ID of the dataset, defaults to the one we use in the
#'   Steno UK Biobank DARE project.
#'
#' @return Outputs character string of the results from the command sent to RAP.
#'
#' @examples
#' \dontrun{
#' proj_create_dataset(
#'   c("eid", "p31", "p34"),
#'   proj_create_path_dataset(rap_get_user())
#' )
#' }
proj_create_dataset <- function(fields,
                                 output_path,
                                 database_id = dare_project_record_id) {
  checkmate::assert_character(fields)
  checkmate::assert_character(database_id)
  checkmate::assert_scalar(database_id)
  checkmate::assert_character(output_path)
  checkmate::assert_scalar(output_path)

  fields <- paste0(glue::glue("-ifield_names={fields}"), collapse = " ")

  cli::cli_alert_info("Sent request to RAP to create a subset of the database into the {.val {output_path}} file.")
  cli::cli_alert_warning("This function can take a while. You can watch it in RAP Monitor.")
  run_dx(c(
    "run",
    "app-table-exporter",
    "--brief",
    "--priority", "high",
    "-y",
    # raw to reduce runtime
    "-icoding_option=raw",
    fields,
    glue::glue("-idataset_or_cohort_or_dashboard={database_id}"),
    glue::glue("-ioutput={fs::path_ext_remove(output_path)}")
  ))
}
