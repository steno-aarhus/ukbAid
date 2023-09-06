#' Add and commit a file to the Git history.
#'
#' @param file File to commit.
#' @param message Commit message.
#'
#' @return Nothing. Adds and commits a file.
#' @keywords internal
#' @noRd
#'
git_commit_file <- function(file, message) {
    stopifnot(is.character(file), is.character(message))
    gert::git_add(file)
    gert::git_commit(message)
    return(invisible(NULL))
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
