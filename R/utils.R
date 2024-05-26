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

run_cli <- function(command) {
  processx::run(command)
}

verify_cli <- function(program, error, call = rlang::caller_env()) {
  command <- glue::glue("which {program}")
  output <- suppressWarnings(run_cli(command))
  if (!length(output)) {
    cli::cli_abort(error, call = call)
  }
  return(invisible())
}
