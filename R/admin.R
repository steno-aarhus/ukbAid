

# Project tracking issue
# - Upload protocol and analysis plan to Zenodo
# - Conduct code review mid-way
# - Conduct code review after analysis is complete
# - Connect GitHub to Zenodo, then create a GitHub release
# - Reference both protocol and code DOI in paper
# - Upload paper to preprint archive (e.g. medRxiv)

#' Add the user to the SDCA GitHub Organization UK Biobank team.
#'
#' @param user The GitHub username.
#'
#' @return Invisibly returns list of results of GitHub API calls. Used for the
#'   side effect of adding user to GitHub.
#' @export
#'
admin_gh_add_user_to_team <- function(user) {
  stopifnot(is.character(user))
  org_invite_results <- ghclass::org_invite(
    org = "steno-aarhus",
    user = user
  )
  team_invite_results <- ghclass::team_invite(
    org = "steno-aarhus",
    team = "ukbiobank-team",
    user = user
  )
  return(invisible(
    list(
      org_invite_results = org_invite_results,
      team_invite_results = team_invite_results
    )
  ))
}

admin_gh_add_repo_to_team <- function(proj_abbrev) {
  ghclass::repo_add_team(
    repo = glue::glue("steno-aarhus/{proj_abbrev}"),
    team = "ukbiobank-team",
    permission = "push"
  )
}

admin_gh_add_user_to_repo <- function(user, proj_abbrev) {
  ghclass::repo_add_user(
    repo = glue::glue("steno-aarhus/{proj_abbrev}"),
    user = user,
    permission = "maintain"
  )
}

admin_create_gh_repo <- function(path) {
  usethis::with_project(
    path = path,
    {
      usethis::use_github(
        organisation = "steno-aarhus",
        private = TRUE
      )
    })
}

admin_gh_list_repos <- function() {
  ghclass::team_repos(
    org = "steno-aarhus",
    team = "ukbiobank-team"
  )
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
  if (any(stringr::str_detect(admin_gh_list_repos()$repo, proj_abbrev))) {
    cli::cli_abort("This project is already on GitHub.")
  }

  temp_proj_path <- fs::path_temp(user, proj_abbrev)
  on.exit(fs::dir_delete(temp_proj_path))
  setup_ukb_project(path = temp_proj_path)
  cli::cli_alert_info("Created the project in the local, temporary location.")
  admin_create_gh_repo(path = temp_proj_path)
  cli::cli_alert_info("Pushed the repo to GitHub.")

  admin_gh_add_user_to_team(user = user)
  admin_gh_add_repo_to_team(proj_abbrev = proj_abbrev)
  admin_gh_add_user_to_repo(user = user, proj_abbrev = proj_abbrev)
  cli::cli_alert_info("Connected the user and team to the repo, with the right permissions.")
  return(invisible())
}

#' List the approved projects connected to the UK Biobank at SDCA.
#'
#' @return A tibble of project details.
#' @export
#'
admin_list_approved_projects <- function() {
  if (basename(usethis::proj_get()) != "ukbAid") {
    cli::cli_abort("You're running this function outside of the {.val 'ukbAid'} project. You need to be inside it to run this function.")
  }
  fs::dir_ls(fs::path("data-raw", "projects", "approved")) |>
    purrr::map(yaml::read_yaml) %>%
    purrr::map(tibble::as_tibble) %>%
    purrr::list_rbind(names_to = "project_abbrev") %>%
    dplyr::mutate(project_abbrev = fs::path_file(project_abbrev) |>
                    fs::path_ext_remove())
}

# Building website --------------------------------------------------------

#' Builds the full website.
#'
#' @return Nothing. Side effect of building the Quarto and pkgdown websites.
#' @keywords internal
#' @noRd
#'
admin_build_site <- function() {
  build_pkgdown_site()
  build_quarto_site()
  return(invisible(NULL))
}

#' Builds only the Quarto website in the vignettes folder.
#'
#' @return Nothing. Side effect of building the Quarto website.
#' @keywords internal
#' @noRd
#'
build_quarto_site <- function() {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    rlang::abort("Please install Quarto to use this function.")
  }
  withr::with_dir(
    new = fs::path_package("vignettes", package = "ukbAid"),
    {quarto::quarto_render(as_job = FALSE)}
  )
  return(invisible(NULL))
}

#' Builds only the pkgdown site for the functions docs.
#'
#' @return Nothing. Used for the side effect of building the pkgdown site.
#' @keywords internal
#' @noRd
#'
build_pkgdown_site <- function() {
  if (!requireNamespace("pkgdown", quietly = TRUE)) {
    rlang::abort("Please install pkgdown to use this function.")
  }

  pkgdown::init_site()
  pkgdown::build_home(preview = FALSE)
  pkgdown::build_reference(preview = FALSE)
  pkgdown::build_news(preview = FALSE)
  return(invisible(NULL))
}
