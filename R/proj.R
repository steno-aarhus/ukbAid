# Get ---------------------------------------------------------------------

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

#' Get package dependencies from the DESCRIPTION file.
#'
#' @return A character vector of package names.
#' @export
#'
proj_get_dependencies <- function() {
  desc::desc_get_deps()$package |>
    stringr::str_subset("^R$", negate = TRUE)
}

#' Search Git's global config settings and list the user's name and email.
#'
#' @return A tibble with the user's name and email.
#' @export
#'
#' @examples
#' proj_get_git_config()
proj_get_git_config <- function() {
    gert::git_config_global() %>%
        dplyr::filter(name %in% c("user.name", "user.email")) %>%
        dplyr::arrange(name) %>%
        dplyr::select(name, value)
}

# proj_get_rstudio_config()

# Setup -------------------------------------------------------------------

#' Add your name and email to Git's config settings.
#'
#' @param name Your full name, for instance "Luke W. Johnston".
#' @param email Your most commonly used email.
#'
#' @return Tibble with changed config settings. Also has side effect of
#'   modifying the user.name and user.email settings in Git.
#' @export
#'
proj_setup_git_config <- function(name, email) {
    if (verify_git_config(name = name, email = email)) {
        git_config <- proj_get_git_config()
        cli::cli_alert_info(c(
          "Git config has already been set correctly: ",
          "{.val {git_config$name[2]}} = {.val {git_config$value[2]}}; ",
          "{.val {git_config$name[1]}} = {.val {git_config$value[1]}}"
        ))
        return(invisible(git_config))
    }
    gert::git_config_global_set("user.name", name)
    gert::git_config_global_set("user.email", email)
    cli::cli_alert_success("Git config has been set, see output below.")
    proj_get_git_config()
}

#' Run standard setup tasks in the UKB RAP after opening it up.
#'
#' @return Nothing. Used for it's side effects.
#' @export
#'
proj_setup_rap <- function() {
    if (!interactive()) {
        cli::cli_abort("The `proj_setup_rap()` function only works in interactive mode.")
    }

    # Add some wait time so it isn't popping up so fast.
    Sys.sleep(1.5)

    # Git config
    cli::cli_h1("Setting up your Git")
    cli::cli_alert_info("We need to setup your Git config. Please answer these questions.")
    user_name <- rstudioapi::showPrompt("User name for Git", "What's your full name?")
    Sys.sleep(1.5)
    user_email <- rstudioapi::showPrompt("User email for Git", "What's your email?")
    ukbAid::proj_setup_git_config(user_name, user_email)
    cli::cli_alert_success("Added your name and email to the Git config.")

    # GitHub authentication
    Sys.sleep(1.5)
    cli::cli_h1("Authenticating for GitHub")
    cli::cli_alert_info("We need to set your Git credentials to GitHub. Copy and paste your GitHub PAT below.")
    Sys.sleep(1.5)
    gitcreds::gitcreds_set()

    # Download project
    Sys.sleep(1.5)
    cli::cli_h1("Downloading your GitHub project")
    cli::cli_alert_info("Lastly, we need to download your project. Please answer this question.")
    Sys.sleep(1.5)
    project_repo <- rstudioapi::showPrompt("Git repository for project", "What is the name of your project (should be the same as your GitHub repository)? For instance, Luke's is: mesh.")
    usethis::create_from_github(paste0("steno-aarhus/", project_repo), open = FALSE)
    cli::cli_alert_success("Done! Now you can open the project by clicking the {.val .Rproj} file and following the instructions in the {.val README.md} file.")
    return(invisible(NULL))
}

# proj_setup_rstudio_config()

# Create ------------------------------------------------------------------

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

#' Extract the variables you want from the UKB database and create a CSV dataset.
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

  fields <- glue::glue("-ifield_names={fields}")

  cli::cli_alert_info("Sent request to RAP to create a subset of the database into the {.val {output_path}} file.")
  cli::cli_alert_warning("This function can take a while. You can watch it in RAP Monitor.")
  run_dx(c(
    "run",
    "app-table-exporter",
    "--brief",
    "--instance-type", "mem2_ssd2_v2_x8",
    "--priority", "high",
    "-y",
    # raw to reduce runtime
    "-icoding_option=RAW",
    fields,
    glue::glue("-idataset_or_cohort_or_dashboard={database_id}"),
    glue::glue("-ioutput={fs::path_ext_remove(output_path)}")
  ))
}

# Helpers -----------------------------------------------------------------

#' Check if the Git's global config has already been set correctly.
#'
#' @param name The user's full name.
#' @param email The user's email.
#'
#' @return A logical, TRUE if the config has been set correctly.
#' @noRd
#'
verify_git_config <- function(name, email) {
    configs <- proj_get_git_config()

    already_exists <- FALSE
    if (nrow(configs) == 2)
        already_exists <- all(configs$value[1] == email, configs$value[2] == name)

    return(already_exists)
}
