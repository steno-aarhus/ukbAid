#' Setup the project structure for working within the RAP.
#'
#' @param path File path and name of project.
#'
#' @return Nothing. Used for side effect of making project structure.
#' @export
#'
#' @examples
#'
#' # Run setup_git_config() first before running the setup_ukb_project() function.
#' # ukbAid::setup_git_config("Luke W. Johnston", "lwjohnst@gmail.com")
#' setup_ukb_project(fs::path_temp("testproj"))
#'
setup_ukb_project <- function(path) {
    prodigenr::setup_project(path)
    options(usethis.quiet = TRUE)
    # Get them to add git config settings (everytime I think)
    usethis::with_project(path, code = {
        gert::git_init()
        gert::git_add(".")
        gert::git_commit("First commit and creation of project")

        # DESCRIPTION file changes
        desc::desc_del_dep("distill")
        desc::desc_set_dep("tidyverse", type = "Imports")
        desc::desc_set_dep("here", type = "Imports")
        desc::desc_set_dep("remotes", type = "Imports")
        desc::desc_set_dep("gert", type = "Imports")
        desc::desc_set_dep("renv", type = "Imports")
        desc::desc_set_dep("targets", type = "Imports")
        desc::desc_set_dep("usethis", type = "Imports")
        desc::desc_set_dep("ukbAid", type = "Imports")
        desc::description$new()$set_remotes("steno-aarhus/ukbAid")$write()
        usethis::use_blank_slate("project")
        git_commit_file("DESCRIPTION", "Add some package dependencies to the project")

        # Updates to the gitignore
        usethis::use_git_ignore("data/data.csv")
        usethis::use_git_ignore(".Rhistory")
        usethis::use_git_ignore(".RData")
        usethis::use_git_ignore(".DS_Store")
        git_commit_file(".gitignore", "Add files that Git should ignore")

        # Add processing files to the data-raw folder
        fs::dir_create("data-raw")
        usethis::use_template("download-data.R", "data-raw/download-data.R", package = "ukbAid")
        git_commit_file("data-raw", "Add R scripts used for getting raw data from UKB")
        readr::write_csv(project_variables, "data-raw/project-variables.csv")
        git_commit_file("data-raw/project-variables.csv", "Add project variables as csv found in the project")
        readr::write_csv(rap_variables, "data-raw/rap-variables.csv")
        git_commit_file("data-raw/rap-variables.csv", "Add variable list that is specific to RAP")

        # Add protocol to `doc/` folder
        rmarkdown::draft(file = "doc/protocol.Rmd", template = "protocol", package = "ukbAid", edit = FALSE)
        git_commit_file("doc/protocol.Rmd", "Add the template protocol R Markdown document")

        # Add other misc items
        usethis::use_template("targets.R", "_targets.R", package = "ukbAid")
        git_commit_file("_targets.R", "Add targets pipeline to project")

        fs::file_delete("README.md")
        usethis::use_template("project-readme.md", "README.md", package = "ukbAid")
        git_commit_file("README.md", "Update the README with the version from ukbAid")

        fs::file_delete("TODO.md")
        usethis::use_template("todo.md", "TODO.md", package = "ukbAid")
        git_commit_file("TODO.md", "Update the TODO file with the version from ukbAid")

        # Add renv setup (as recommended by RAP)
        renv::init(settings = renv::settings$snapshot.type(value = "explicit"), restart = FALSE)
        git_commit_file(".", "Add renv support files to project")
    })
}
