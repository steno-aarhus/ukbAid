# Follow the comments below to fill in this target script.

# Load packages required to define the pipeline:
library(targets)

# Load the R scripts with your custom functions:
# source(here::here("R/functions.R"))

# Things to run in order to work.
list(
    tar_target(
        name = install_renv,
        command = install.packages("renv")
    ),
    tar_target(
        name = install_packages_with_renv,
        command = renv::restore()
    ),
    # # Uncomment this only while inside the RAP environment.
    # tar_target(
    #     name = set_git_config_global,
    #     # TODO: replace "FULL NAME" with your name
    #     # TODO: replace "youremail@email.com" with your email address
    #     command = ukbAid::setup_git_config("FULL NAME", "youremail@email.com")
    # ),
    # tar_target(
    #     name = download_project_data,
    #     command = source(here::here("data-raw/download-data.R"))
    # )
)
