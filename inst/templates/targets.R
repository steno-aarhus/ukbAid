# Load packages required to define the pipeline:
library(targets)
library(ukbAid)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = proj_get_dependencies(),
  format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # This likely isn't necessary for most UK Biobank users at SDCA/AU.
  # For distributed computing in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller with 2 workers which will run as local R processes:
  #
  #   controller = crew::crew_controller_local(workers = 2)
  #
)

# Run the R scripts in the R/ folder with your custom functions:
# tar_source()
# Or just some files:
# source(here::here("R/functions.R"))

# Things to run in order to work.
list(
    # TODO: Uncomment this *after* finishing running `data-raw/create-data.R`
    # tar_target(
    #     name = project_data,
          # TODO: This will eventually need to be changed to "parquet".
        # command = rap_copy_from(
        #   rap_get_path_user_files(user = rap_get_user()) |>
        #     sort() |>
        #     head(1),
        #   here::here("data/data.csv")
        # ),
    #     format = "file"
    # )
)
