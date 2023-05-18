#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL


#' All variables found within the UK Biobank
#'
#' A dataframe that contains the IDs and variable descriptions for the variables
#' contained in the Steno DARE project on the UKB RAP.
#'
#' @format A data frame with 7663 rows and 3 variables:
#' \describe{
#'   \item{id}{The ID for the "field" (or variable). Used to connect to the `rap_variables.csv` file.}
#'   \item{ukb_variable_description}{Brief description of the variable.}
#'   \item{link}{URL to the description of the variable.}
#' }
#' @source \url{https://biobank.ndph.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.tsv}
"project_variables"

#' Variable names that are specific to the RAP
#'
#' A dataframe that contains the field IDs and variable names that are specific
#' to the RAP database and used to select from it.
#'
#' @format A data frame with 22,355 rows and 3 variables:
#' \describe{
#'   \item{id}{The ID for the "field" (or variable). Used when connecting with the `project_variables.csv` file.}
#'   \item{field_id}{The RAP ID for the "field" (or variable). "Instance" is the
#'   time point and "Array" is how the variable was split up with e.g. some
#'   questionnaire variables.}
#'   \item{rap_variable_name}{The name of the variable in the RAP database.}
#' }
"rap_variables"
