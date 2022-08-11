
# Keep only the necessary variables for RAP -------------------------------

# After the variables have been properly selected in the `data-raw/project-variables.csv`
# file, run this function so that only the selected variables are kept in the
# `data-raw/rap-variables.csv` file. This file has the exact variable names used
# by RAP that we need in order to create the project-specific dataset. After
# running this function, review the changes and add and commit the changed
# files into Git.
ukbAid::subset_rap_variables()

# Create the project dataset and save inside RAP --------------------------

# Uncomment and run *ONLY AFTER* running the above function. After running this
# code and creating the csv file in the main RAP project folder, comment it
# out again so you don't run it anymore.
# read_csv(here::here("data-raw/rap-variables.csv")) %>%
#     pull(variable_name) %>%
#     ukbAid::create_csv_from_database()

# Download the project data from RAP into the session ---------------------

# Uncomment (and keep uncommented) and run after running the code above and
# letting it create your csv file of the data you want.
# ukbAid::download_project_data()
