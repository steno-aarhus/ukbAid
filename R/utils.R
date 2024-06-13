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

verify_cli <- function(program, error, call = rlang::caller_env()) {
  output <- processx::run(
    "which",
    program,
    error_on_status = FALSE
  )
  if (output$status) {
    cli::cli_abort(error, call = call)
  }
  return(invisible())
}
