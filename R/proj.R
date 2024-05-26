#' Get the RAP project ID, will be the project main folder.
#'
#' @return The project abbreviation/id, which is the name of the project folder
#'   (and the same as the name of the `.Rproj` folder).
#' @export
#'
get_rap_project_id <- function() {
  options(usethis.quiet = TRUE)
  on.exit(options(usethis.quiet = NULL))
  fs::path_file(usethis::proj_path())
}

#' Get package dependencies from the DESCRIPTION file.
#'
#' @return A character vector of package names.
#' @export
#'
get_proj_dependencies <- function() {
  desc::desc_get_deps()$package |>
    stringr::str_subset("^R$", negate = TRUE)
}
