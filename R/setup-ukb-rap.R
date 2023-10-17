
#' Run standard setup tasks in the UKB RAP after opening it up.
#'
#' @return Nothing. Used for it's side effects.
#' @export
#'
setup_ukb_rap <- function() {
    if (!interactive()) {
        warning("The `setup_ukb_rap()` function only works in interactive mode.")
        return(invisible(NULL))
    }

    # Add some wait time so it isn't popping up so fast.
    Sys.sleep(1.5)
    cli::cli_h1("Setting up your Git")
    cli::cli_alert_info("We need to setup your Git config. Please answer these questions.")
    user_name <- rstudioapi::showPrompt("User name for Git", "What's your full name?")
    Sys.sleep(1.5)
    user_email <- rstudioapi::showPrompt("User email for Git", "What's your email?")
    ukbAid::setup_git_config(user_name, user_email)
    cli::cli_alert_success("Added your name and email to the Git config.")

    Sys.sleep(1.5)
    cli::cli_h1("Authenticating for GitHub")
    cli::cli_alert_info("We need to set your Git credentials to GitHub. Copy and paste your GitHub PAT below.")
    Sys.sleep(1.5)
    gitcreds::gitcreds_set()

    Sys.sleep(1.5)
    cli::cli_h1("Downloading your GitHub project")
    cli::cli_alert_info("Lastly, we need to download your project. Please answer this question.")
    Sys.sleep(1.5)
    project_repo <- rstudioapi::showPrompt("Git repository for project", "What is the name of your project (should be the same as your GitHub repository)? For instance, Luke's is: mesh.")
    usethis::create_from_github(paste0("steno-aarhus/", project_repo), open = FALSE)
    cli::cli_alert_success("Done! Now you can open the project by clicking the {.val .Rproj} file and following the instructions in the {.val README.md} file.")
    return(invisible(NULL))
}


