# Get ---------------------------------------------------------------------

#' Get the Steno GitHub organization.
#'
#' @return A character scalar.
#' @export
#'
#' @examples
#' gh_get_org()
gh_get_org <- function() {
  "steno-aarhus"
}

#' Get the name of the Steno GitHub team for the UK Biobank project.
#'
#' @return A character scalar.
#' @export
#'
#' @examples
#' gh_get_team()
gh_get_team <- function() {
  "ukbiobank-team"
}

#' Get all users who are part of the UK Biobank Steno team on GitHub.
#'
#' @return A character vector of usernames.
#' @export
#'
#' @examples
#' \dontrun{
#' # Need to have a GitHub token set up.
#' gh_get_users()
#' }
gh_get_users <- function() {
  ghclass::team_members(gh_get_org(), gh_get_team())$user
}

#' Get all repo names in the UK Biobank GitHub team.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' \dontrun{
#' # Need to have a GitHub token set up.
#' gh_get_repos()
#' }
gh_get_repos <- function() {
  ghclass::team_repos(gh_get_org(), gh_get_team())$repo |>
    stringr::str_remove("^.*/")
}

# Add ---------------------------------------------------------------------

#' Add the user to the UK Biobank GitHub team.
#'
#' @param user The GitHub username.
#'
#' @return Invisibly returns NULL. Used for the side effect of adding user to
#'   GitHub.
#' @export
#'
gh_add_user_to_team <- function(user) {
  checkmate::assert_character(user)
  ghclass::org_invite(gh_get_org(), user)
  ghclass::team_invite(gh_get_org(), user, gh_get_team())
  return(invisible())
}

#' Add a user to a repo.
#'
#' @inheritParams admin_start_approved_project
#'
#' @return Invisibly returns NULL, used for side effect of sending request to GitHub API.
#' @export
#'
gh_add_user_to_repo <- function(user, repo) {
  user <- rlang::arg_match(user, gh_get_users())
  repo <- rlang::arg_match(repo, gh_get_repos())

  ghclass::repo_add_user(
    repo = glue::glue("{gh_get_org()}/{repo}"),
    user = user,
    permission = "maintain"
  )
}

#' Add a GitHub repo to the UK Biobank Steno team.
#'
#' @param repo The name of the repository.
#'
#' @return Invisibly returns GitHub API response, used for side effect of
#'   sending request to GitHub API.
#' @export
#'
gh_add_repo_to_team <- function(repo) {
  repo <- rlang::arg_match(repo, gh_get_repos())

  ghclass::repo_add_team(
    repo = glue::glue("{gh_get_org()}/{repo}"),
    team = gh_get_team(),
    permission = "push"
  )
}

# Create ------------------------------------------------------------------

#' Create a GitHub repository based on the existing local project.
#'
#' @param path Path to the local RStudio project. Defaults to current working
#'   directory.
#'
#' @return The GitHub API response, used for the side effect of creating a
#'   GitHub repository.
#' @export
#'
gh_create_repo <- function(path = ".") {
  usethis::with_project(
    path = path,
    {
      usethis::use_github(
        organisation = gh_get_org(),
        private = TRUE
      )
    }
  )
}

# Remove ------------------------------------------------------------------

# gh_remove_user_from_team(user)

# Helper functions --------------------------------------------------------

run_gh <- function(command, call = rlang::caller_env()) {
  verify_gh(call = call)
  processx::run(
    "gh",
    command
  )
}

verify_gh <- function(call = rlang::caller_env()) {
  verify_cli(
    program = "gh",
    error = "Please install the GitHub CLI (gh) before proceeding.",
    call = call
  )
}
