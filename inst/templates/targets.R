# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Tell targets your needed packages.
package_deps <- desc::desc_get_deps()$package |>
  stringr::str_subset("^R$", negate = TRUE)

# Set target options:
tar_option_set(
  packages = package_deps,
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
    #     name = download_project_data,
    #     command = ukbAid::download_project_data(),
    #     format = "file"
    # )
)
