
# Really only need to run this script once.

# This function will save the list of variables in the database into this `data-raw/`
# folder as `variables.csv`.
ukbAid::download_database_variables()

# Uncomment and run only after downloading the `variables.csv` file the first time.
# Comment this again after running it.
# gert::git_add(files = here::here("data-raw/variables.csv"))
# gert::git_commit("Added the variable list from the main RAP project into data-raw.")
