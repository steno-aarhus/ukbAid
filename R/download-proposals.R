#' Download project proposals from Google Form.
#'
#' @param most_recent Whether to select only the most recent proposal.
#'
#' @return Invisibly returns data.frame. Used for side effect of saving
#'   proposals as YAML file.
#' @export
#'
admin_download_proposals <- function(most_recent = FALSE) {
  # Use `copy_sheets_colnames()` to get a list of the variable names.
  column_renaming <- c(
    submitted_on = "Timestamp",
    # read_docs = "Have you read the documentation on the website and agree to it (https://steno-aarhus.github.io/ukbAid/)?",
    full_name = "What is your full name?",
    github_username = "What is your GitHub user name? If you do not have a GitHub user, please make one (https://github.com/)",
    # ukb_username = "What is your UK Biobank and RAP user name? If not registered please do so (https://steno-aarhus.github.io/ukbAid/request-access.html)",
    job_position = "What is your position?",
    phd_supervisor = "If you are a PhD student, who is your supervisor?",
    affiliation = "What is your primary affiliation?",
    project_title = "Please provide in a basic title for your proposed project.",
    project_abbrev = "Please provide an abbreviation for your proposed project.",
    project_description = "Please provide a brief description of your proposed project, around 2 to 3 paragraphs. Include an overall aim for your project in the description.",
    agree_to_conditions = "Do you agree to the conditions/expectations listed on the website (https://steno-aarhus.github.io/ukbAid/) for participating in the Steno UKB community?"
  )

  # TODO: Need to find some way to re-authenticate.
  googlesheets4::gs4_deauth()
  proposals <- googlesheets4::read_sheet(get_survey_id())

  if (most_recent) {
    proposals <- proposals |>
      dplyr::filter(Timestamp == max(Timestamp))
  }

  proposals <- proposals |>
    dplyr::select(column_renaming) |>
    dplyr::mutate(
      submitted_on = lubridate::format_ISO8601(submitted_on, precision = "ymd"),
      dplyr::across(tidyselect::where(is.na), ~""),
      dplyr::across(tidyselect::everything(), ~as.character(.x) |>
                      stringr::str_remove_all("\n"))
    )

  proposals |>
    tidyr::nest(.by = project_abbrev) |>
    purrr::pwalk(\(project_abbrev, data) {
      writeLines(
        text = yaml::as.yaml(data),
        con = here::here("data-raw", "projects", "proposals", paste0(project_abbrev, ".yaml"))
      )
    })

  return(invisible(proposals))
}

# Helpers -----------------------------------------------------------------

get_survey_id <- function() {
  survey_id <- Sys.getenv("SURVEY_ID")
  if (survey_id == "") {
    survey_id <- rstudioapi::showPrompt("Google Sheets ID", "What is the ID for the Google Sheet?")
    Sys.setenv(SURVEY_ID = survey_id)
  }
  return(survey_id)
}

copy_sheets_colnames <- function() {
  if (!requireNamespace("clipr", quietly = TRUE)) {
    cli::cli_abort("Please install the {.pkg clipr} package to use this function.")
  }
  get_survey_id() |>
    googlesheets4::read_sheet() |>
    names() |>
    clipr::write_clip()
}
