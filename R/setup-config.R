
#' Add your name and email to Git's config settings.
#'
#' @param name Your full name, for instance "Luke W. Johnston".
#' @param email Your most commonly used email.
#'
#' @return Tibble with changed config settings. Also has side effect of
#'   modifying the user.name and user.email settings in Git.
#' @export
#'
setup_git_config <- function(name, email) {
    if (check_if_git_config_already_exists(name = name, email = email)) {
        git_config <- list_git_config_user_and_email()
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
    list_git_config_user_and_email()
}

#' Search Git's global config settings and list the user's name and email.
#'
#' @return A tibble with the user's name and email.
#' @noRd
#'
list_git_config_user_and_email <- function() {
    gert::git_config_global() %>%
        dplyr::filter(name %in% c("user.name", "user.email")) %>%
        dplyr::arrange(name) %>%
        dplyr::select(name, value)
}

#' Check if the Git's global config has already been set correctly.
#'
#' @param name The user's full name.
#' @param email The user's email.
#'
#' @return A logical, TRUE if the config has been set correctly.
#' @noRd
#'
check_if_git_config_already_exists <- function(name, email) {
    configs <- list_git_config_user_and_email()

    already_exists <- FALSE
    if (nrow(configs) == 2)
        already_exists <- all(configs$value[1] == email, configs$value[2] == name)

    return(already_exists)
}
