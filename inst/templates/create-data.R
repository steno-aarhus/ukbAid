
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

# readr::read_csv(here::here("data-raw/rap-variables.csv")) %>%
#     dplyr::pull(id) %>%
#     ukbAid::create_csv_from_database()
