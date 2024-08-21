
# Keep only the necessary variables for RAP -------------------------------

library(magrittr)

# Select the RAP variables you want by deleting rows in the `data-raw/rap-variables.csv`
# file. Run the commented function below if you want to start over (I suggest
# you keep a copy or make sure to track edits to the file in Git).

# Uncomment if you messed up and need to start over.
# ukbAid::rap_variables %>%
#     readr::write_csv(here::here("data-raw/rap-variables.csv"))

# Create the project dataset and save inside RAP --------------------------

# Uncomment and run the below lines **ONLY AFTER** selecting the variables from above.
# After running this code and creating the csv file in the main RAP project
# folder, comment it out again so you don't accidentally run it anymore (unless
# you need to re-create the dataset).

# dataset_filename <- ukbAid::proj_create_path_dataset()
# # Create the dataset csv file.
# readr::read_csv(here::here("data-raw/rap-variables.csv")) %>%
#     dplyr::pull(id) %>%
#     ukbAid::proj_create_dataset(
#       output_path = dataset_filename
#     )

# # Move the created dataset over.
# ukbAid::rap_move_file(
#   dataset_filename,
#   ukbAid::rap_get_path_users() |>
#   TODO: Change this to the actual user name
#   stringr::str_subset(ukbAid::rap_get_user())
# )
