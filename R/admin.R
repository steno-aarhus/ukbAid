# Create project repo with all permissions --------------------------------



# Projects ----------------------------------------------------------------

#' Read all approved projects.
#'
#' Show all approved projects, which are stored in YAML files, using the UK
#' Biobank at SDCA. Display this information as a [tibble::tibble()].
#'
#' @return A tibble of project details.
#' @export
#'
admin_read_projects <- function() {
  verify_ukbaid()
  admin_get_project_ids() |>
    purrr::map(admin_read_project)
}

admin_read_project <- function(id) {
  verify_ukbaid()
  id <- rlang::arg_match(id, admin_get_project_ids())

  admin_get_path_projects() |>
    stringr::str_subset(id) |>
    yaml::read_yaml() |>
    tibble::as_tibble() |>
    dplyr::mutate(id = id)
}

admin_get_path_projects <- function() {
  verify_ukbaid()
  rprojroot::find_package_root_file() |>
    fs::path("data-raw", "projects", "approved") |>
    fs::dir_ls()
}

admin_get_project_ids <- function() {
  verify_ukbaid()
  admin_get_path_projects() |>
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

  temp_proj_path <- fs::path_temp(user, proj_abbrev)
  on.exit(fs::dir_delete(temp_proj_path))
  setup_ukb_project(path = temp_proj_path)
  cli::cli_alert_info("Created the project in the local, temporary location.")
  admin_create_gh_repo(path = temp_proj_path)
  cli::cli_alert_info("Pushed the repo to GitHub.")

  gh_add_user_to_team(user = user)
  gh_add_repo_to_team(repo = proj_abbrev)
  gh_add_user_to_repo(user = user, repo = proj_abbrev)
  cli::cli_alert_info("Connected the user and team to the repo, with the right permissions.")
  return(invisible())
}

# Helpers -----------------------------------------------------------------

verify_ukbaid <- function(call = rlang::caller_env()) {
  if (basename(rprojroot::find_package_root_file()) != "ukbAid") {
    cli::cli_abort(
      "You can only run this function while inside the {.val 'ukbAid'} project.",
      call = call)
  }
  return(invisible())
}
