#' Add and commit a file to the Git history.
#'
#' @param file File to commit.
#' @param message Commit message.
#'
#' @return Nothing. Adds and commits a file.
#' @noRd
#'
git_commit_file <- function(file, message) {
    stopifnot(is.character(file), is.character(message))
    gert::git_add(file)
    gert::git_commit(message)
    return(invisible())
}
