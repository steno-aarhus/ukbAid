#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

#' Variable names that are specific to the RAP
#'
#' A [tibble::tibble()] that contains the field (variable) IDs and titles that are specific
#' to the RAP database and used to select from it.
#'
#' @format A data frame with 27,929 rows and 2 variables:
#' \describe{
#'   \item{field_id}{The ID for the "field" (or variable) within the RAP UK Biobank dataset,
#'   which represents the column in the dataset.}
#'   \item{field_title}{The RAP variable title for the "field" (or variable). "Instance" is the
#'   time point and "Array" is how the variable was split up with e.g. some
#'   questionnaire variables. This is the human readable format.}
#' }
"rap_variables"

#' Textual statements required by UK Biobank.
#'
#' A list that contains two items, one to use in protocols and another to use
#' in a paper.
#'
#' @format A list with 2 items:
#' \describe{
#'   \item{protocol}{A text statement to include in the protocol.}
#'   \item{paper}{A text statement to include in the paper.}
#' }
"statements"
