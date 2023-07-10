
# Tracking issue
#

# First issue
# - review proposal and provide feedback
# - accept proposal

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
