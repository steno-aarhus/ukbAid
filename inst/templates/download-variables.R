
# Script to download and save the RAP variables to data-raw/ --------------

# Really only need to run this script once.

# This function will save the list of variables in the database into this `data-raw/`
# folder as `rap-variables.csv`.
ukbAid::download_database_variables()
ukbAid::git_commit_database_variables()
