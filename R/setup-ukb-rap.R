
#' Run standard setup tasks in the UKB RAP after opening it up.
#'
#' @return Nothing. Used for it's side effects.
#'
setup_ukb_rap <- function() {
    if (!interactive()) {
        warning("The `setup_ukb_rap()` function only works in interactive mode.")
        return(invisible(NULL))
    }

    options(repos = c(RSPM = "https://packagemanager.rstudio.com/all/__linux__/focal/latest"))
    try(rspm::enable(), silent = TRUE)
    install.packages("yesno", quiet = TRUE)
    if (yesno::yesno2("Install the ukbAid package, along with the remotes package?")) {
        install.packages("remotes", quiet = TRUE)
        remotes::install_github("steno-aarhus/ukbAid")
    } else {
        stop("You need to install the necessary packages to continue with the setup. Please re-run the function.")
    }

    cli::cli_alert_info("We need to setup your Git config. Please answer these questions.")
    user_name <- rstudioapi::showPrompt("User name for Git", "What's your full name?")
    user_email <- rstudioapi::showPrompt("User email for Git", "What's your email?")
    ukbAid::setup_git_config(user_name, user_email)
    cli::cli_alert_success("Added your name and email to the Git config.")

    cli::cli_rule()
    cli::cli_alert_info("We need to set your Git credentials to GitHub. Copy and paste your GitHub PAT below.")
    gitcreds::gitcreds_set()

    cli::cli_rule()
    cli::cli_alert_info("Lastly, we need to download your project. Please answer this question.")
    project_repo <- rstudioapi::showPrompt("Git repository for project", "What is the GitHub repository location for your project? It should be in the form 'username/reponame', for instance, mine is lwjohnst86/mesh (without quotes).")
    usethis::create_from_github(project_repo, open = FALSE)
    cli::cli_alert_success("Done! Now you can open the project by clicking the `.Rproj` file and following the instructions in the `README.md` file.")
    return(invisible(NULL))
}


