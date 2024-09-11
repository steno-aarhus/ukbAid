# Projects ----------------------------------------------------------------



#' Read all approved projects.
#'
#' Show all approved projects, which are stored in YAML files, using the UK
#' Biobank at SDCA. Display this information as a [tibble::tibble()].
#'
#' @return A tibble of project details.
#' @export
#'
#' @examples
#' \dontrun{
#' admin_read_projects()[[1]]
#' }
admin_read_projects <- function(type = "approved") {
  verify_ukbaid()
  admin_get_project_ids(type) |>
    purrr::map(\(id) admin_read_project(id = id, type = type))
}

admin_read_project <- function(id, type = "approved") {
  verify_ukbaid()
  id <- rlang::arg_match(id, admin_get_project_ids(type))

  admin_get_path_projects(type) |>
    stringr::str_subset(id) |>
    yaml::read_yaml() |>
    tibble::as_tibble() |>
    dplyr::mutate(id = id) |>
    dplyr::bind_rows(
      tibble::tibble(
        doi_published = character(),
        doi_protocol = character(),
        doi_preprint = character(),
        doi_repo = character()
      )
    )
}

admin_get_path_projects <- function(type = c("approved", "completed", "abandoned")) {
  verify_ukbaid()
  type <- rlang::arg_match(type)
  rprojroot::find_package_root_file() |>
    fs::path("data-raw", "projects", type) |>
    fs::dir_ls()
}

admin_get_project_ids <- function(type = "approved") {
  verify_ukbaid()
  admin_get_path_projects(type) |>
    fs::path_file() |>
    fs::path_ext_remove()
}

#' Start and setup the approved project onto GitHub.
#'
#' @param user The GitHub username.
#' @param proj_abbrev The abbreviation for the project.
#'
#' @return Nothing, used for the side effects of making a project and setting up
#'   the GitHub repo.
#' @export
#'
admin_start_approved_project <- function(user, proj_abbrev) {
  if (any(stringr::str_detect(gh_get_repos(), proj_abbrev))) {
    cli::cli_abort("This project is already on GitHub.")
  }
  user <- rlang::arg_match(user, gh_get_users())

  temp_proj_path <- fs::path_temp(user, proj_abbrev)
  on.exit(fs::dir_delete(temp_proj_path))
  admin_create_project(path = temp_proj_path)
  cli::cli_alert_info("Created the project in the local, temporary location.")
  gh_create_repo(temp_proj_path)
  cli::cli_alert_info("Pushed the repo to GitHub.")

  gh_add_user_to_team(user = user)
  gh_add_repo_to_team(repo = proj_abbrev)
  gh_add_user_to_repo(user = user, repo = proj_abbrev)
  cli::cli_alert_info("Connected the user and team to the repo, with the right permissions.")
  return(invisible())
}

#' Setup the project structure for working within the RAP.
#'
#' @param path File path and name of project.
#'
#' @return Nothing. Used for side effect of making project structure.
#' @export
#'
#' @examples
#' \dontrun{
#' # Run proj_setup_git_config() first before running the admin_create_project() function.
#' # ukbAid::proj_setup_git_config("Luke W. Johnston", "lwjohnst@gmail.com")
#' admin_create_project(fs::path_temp("testproj"))
#' }
admin_create_project <- function(path) {
  prodigenr::setup_project(path)
  options(usethis.quiet = TRUE)
  # Get them to add git config settings (everytime I think)
  usethis::with_project(path, code = {
    gert::git_config_global_set("init.defaultbranch", "main")
    gert::git_init()
    gert::git_add(".")
    gert::git_commit("First commit and creation of project")

    # DESCRIPTION file changes
    desc::desc_del_dep("distill")
    desc::desc_set_dep("qs", type = "Imports")
    desc::desc_set_dep("quarto", type = "Imports")
    desc::desc_set_dep("tidyverse", type = "Imports")
    desc::desc_set_dep("here", type = "Imports")
    desc::desc_set_dep("gert", type = "Imports")
    desc::desc_set_dep("targets", type = "Imports")
    desc::desc_set_dep("usethis", type = "Imports")
    desc::desc_set_dep("ukbAid", type = "Imports")
    desc::description$new()$set_remotes("steno-aarhus/ukbAid")$write()
    usethis::use_blank_slate("project")
    git_commit_file("DESCRIPTION", "Add some package dependencies to the project")

    desc::desc_set(Title = "UK Biobank Project")
    desc::desc_set(Version = "0.0")
    git_commit_file("DESCRIPTION", "Add a title to the description file")

    # Updates to the gitignore
    usethis::use_git_ignore(c("data/data.*", ".Rhistory", ".RData", ".DS_Store", ".Rbuildignore"))
    git_commit_file(".gitignore", "Add files that Git should ignore")

    # Add processing files to the data-raw folder
    fs::dir_create("data-raw")
    usethis::use_template("create-data.R", "data-raw/create-data.R", package = "ukbAid")
    git_commit_file("data-raw", "Add R scripts used for getting raw data from UKB")
    readr::write_csv(rap_variables, "data-raw/rap-variables.csv")
    git_commit_file("data-raw/rap-variables.csv", "Add variable list that is specific to RAP")

    # Add protocol to `doc/` folder
    usethis::use_template("protocol.qmd", "doc/protocol.qmd", package = "ukbAid")
    git_commit_file("doc/protocol.qmd", "Add the template protocol Quarto document")

    # Add other misc items
    usethis::use_template("targets.R", "_targets.R", package = "ukbAid")
    git_commit_file("_targets.R", "Add targets pipeline to project")

    fs::file_delete("README.md")
    usethis::use_template("project-readme.md", "README.md", package = "ukbAid")
    git_commit_file("README.md", "Update the README with the version from ukbAid")

    fs::file_delete("TODO.md")
    usethis::use_template("todo.md", "TODO.md", package = "ukbAid")
    git_commit_file("TODO.md", "Update the TODO file with the version from ukbAid")

    usethis::use_mit_license()
    fs::file_delete("LICENSE")
    git_commit_file("LICENSE", "Add MIT License to the project")
    git_commit_file("DESCRIPTION", "Update the DESCRIPTION file with the MIT License")
  })
}

admin_list_projects_as_md <- function(type = "approved") {
  project_description_template <- "
    \n
    ### {id}: {project_title}
    \n
    {project_description}
    \n
    - Lead author: {full_name}, {job_position} at {affiliation}
    - GitHub repository: [github.com/steno-aarhus/{id}](https://github.com/steno-aarhus/{id})
    {doi}
    "
  admin_read_projects(type) |>
    purrr::map(\(project) format_doi_as_md_list(project)) |>
    purrr::map(\(project) glue::glue_data(project, project_description_template)) %>%
    purrr::walk(\(text) cat(text, sep = "\n\n"))
}

# Proposals ---------------------------------------------------------------

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
      dplyr::across(tidyselect::everything(), ~ as.character(.x) |>
        stringr::str_remove_all("\n"))
    )

  proposals |>
    tidyr::nest(.by = project_abbrev) |>
    purrr::pwalk(\(project_abbrev, data) {
      proposal_file <- rprojroot::find_package_root_file(
        "data-raw",
        "projects",
        "proposals",
        paste0(project_abbrev, ".yaml")
      )
      fs::dir_create(fs::path_dir(proposal_file))
      fs::file_create(proposal_file)
      readr::write_lines(
        x = yaml::as.yaml(data),
        file = proposal_file
      )
    })

  return(invisible(proposals))
}

# Websites ----------------------------------------------------------------

#' Builds the full website.
#'
#' @return Nothing. Side effect of building the Quarto and pkgdown websites.
#' @keywords internal
#' @noRd
#'
admin_build_site <- function() {
  admin_build_pkgdown()
  admin_build_quarto()
  return(invisible(NULL))
}

#' Builds only the Quarto website in the vignettes folder.
#'
#' @return Nothing. Side effect of building the Quarto website.
#' @keywords internal
#'
admin_build_quarto <- function() {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    rlang::abort("Please install Quarto to use this function.")
  }
  withr::with_dir(
    new = fs::path_package("vignettes", package = "ukbAid"),
    {
      quarto::quarto_render(as_job = FALSE)
    }
  )
  return(invisible(NULL))
}

#' Builds only the pkgdown site for the functions docs.
#'
#' @return Nothing. Used for the side effect of building the pkgdown site.
#' @keywords internal
#'
admin_build_pkgdown <- function() {
  if (!requireNamespace("pkgdown", quietly = TRUE)) {
    rlang::abort("Please install pkgdown to use this function.")
  }

  pkgdown::init_site()
  pkgdown::build_home(preview = FALSE)
  pkgdown::build_reference(preview = FALSE)
  pkgdown::build_news(preview = FALSE)
  return(invisible(NULL))
}

# Helpers -----------------------------------------------------------------

verify_ukbaid <- function(call = rlang::caller_env()) {
  if (basename(rprojroot::find_package_root_file()) != "ukbAid") {
    cli::cli_abort(
      "You can only run this function while inside the {.val 'ukbAid'} project.",
      call = call
    )
  }
  return(invisible())
}

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

#' Add and commit a file to the Git history.
#'
#' @param file File to commit.
#' @param message Commit message.
#'
#' @return Nothing. Adds and commits a file.
#' @keywords internal
#'
git_commit_file <- function(file, message) {
  stopifnot(is.character(file), is.character(message))
  gert::git_add(file)
  gert::git_commit(message)
  return(invisible(NULL))
}

format_doi_as_md_list <- function(data) {
  doi_as_md_list <- data |>
    dplyr::select(tidyselect::starts_with("doi")) |>
    tidyr::pivot_longer(
      cols = tidyselect::everything(),
      names_to = "type", values_to = "doi"
    ) |>
    tidyr::drop_na() |>
    dplyr::mutate(
      type = stringr::str_remove(type, "doi_") |>
        stringr::str_to_sentence(),
      doi = glue::glue("- {type}: [{doi}](https://doi.org/{doi})")
    ) |>
    dplyr::pull(doi) |>
    stringr::str_c(collapse = "\n")
  data |>
    dplyr::mutate(doi = doi_as_md_list)
}
