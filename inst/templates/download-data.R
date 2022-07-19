
library(tidyverse)
library(ukbAid)

# Uncomment and run *ONLY AFTER* keeping the variables you want in the
# `data-raw/variables.csv` and deleting all over variables from the file.
# After running this code and creating the csv file in the main RAP project folder,
# then comment it out again so you don't run it anymore.
# read_csv(here::here("data-raw/variables.csv")) %>%
#     pull(variable_name) %>%
#     create_csv_from_database()

# Uncomment (and keep uncommented) and run after running the code above and
# letting it create your csv file of the data you want.
# download_project_data()
