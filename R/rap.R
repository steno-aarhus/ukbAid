# Get ---------------------------------------------------------------------

#' Get the username of the user who is working within the RAP RStudio session.
#'
#' @return Character vector with users username within the RAP session.
#' @export
#'
#' @examples
#' \dontrun{
#' rap_get_user()
#' }
rap_get_user <- function() {
  run_dx("whoami")
}

#' Get the paths of all the users within the RAP project server.
#'
#' @return Character vector of folder paths.
#' @export
#'
#' @examples
#' \dontrun{
#' rap_get_path_users()
#' }
rap_get_path_users <- function() {
  rap_get_path_dirs("users/")
}

#' Get the paths of files in a single users folder within the RAP project server.
#'
#' @param user A user's username. Default is currently logged in user.
#'
#' @return A character vector of files in a user's folder.
#' @export
#'
#' @examples
#' \dontrun{
#' rap_get_path_user_files("danibs")
#' }
rap_get_path_user_files <- function(user = rap_get_user()) {
  users <- rap_get_path_users()
  user <- rlang::arg_match(
    user,
    users |>
      stringr::str_remove("/$") |>
      stringr::str_remove("^/users/")
  )
  user <- users |>
    stringr::str_subset(user)

  rap_get_path_files(user)
}

#' Get paths of files within a folder based on a given path in the RAP project server.
#'
#' @param path The path to search for files.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' \dontrun{
#' rap_get_path_files(".")
#' }
rap_get_path_files <- function(path) {
  run_dx(c("ls", "--all", "--obj", path)) |>
    stringr::str_subset("^/\\/\\.\\.?/$", negate = TRUE)
}

#' Get full paths of folders within the RAP project server.
#'
#' @param path The path that you want to see the folders within.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' \dontrun{
#' rap_get_path_dirs("users/")
#' }
rap_get_path_dirs <- function(path) {
  run_dx(c("ls", "--all", "--full", "--folders", path))
}

#' Get the path to the RAP UK Biobank dataset.
#'
#' @return A path as a scalar character.
#' @export
#'
rap_get_path_database <- function() {
  rap_get_path_files(".") |>
    stringr::str_subset("\\.dataset$")
}

#' Get the path to the RAP UK Biobank schema.
#'
#' @return A path as a scalar character.
#' @export
#'
rap_get_path_schema <- function() {
  rap_get_path_files(".") |>
    stringr::str_subset("\\.json\\.gz")
}

# Copying/moving -----------------------------------------------------------------

#' Copying files between the RAP server and the RStudio RAP environment.
#'
#' @name rap_copy
#' @param local_path The path within the RStudio environment in the RAP.
#' @param rap_path The path within the RAP project server.
#'
#' @return The path of the copied file.
#'
NULL

#' @describeIn rap_copy Copying from the "local" RStudio environment on the RAP
#'   and into the RAP project server.
#' @export
rap_copy_to <- function(local_path, rap_path) {
  run_dx(c("upload", local_path, "--destination", rap_path))
  rap_path
}

#' @describeIn rap_copy Copying from the RAP project server and into the "local"
#'   RStudio environment on the RAP.
#' @export
rap_copy_from <- function(rap_path, local_path) {
  run_dx(c(
    "download", rap_path, "--output", local_path,
    "--overwrite", "--no-progress", "--lightweight"
  ))
  local_path
}

#' Move a file from one location to another within the RAP project server.
#'
#' @param path The file path you want to move.
#' @param output_dir The folder (directory) you want to move the file to.
#'
#' @return The status results of the move command.
#' @export
#'
#' @examples
#' \dontrun{
#' rap_get_path_files(".") |>
#'   stringr::str_subset("lwjohnst-.*\\.csv$") |>
#'   rap_move_file(
#'     rap_get_path_users() |>
#'       stringr::str_subset("lwjohnst")
#'   )
#' }
rap_move_file <- function(path, output_dir) {
  checkmate::assert_character(path)
  checkmate::assert_character(output_dir)
  checkmate::assert_scalar(path)
  checkmate::assert_scalar(output_dir)

  run_dx(c(
    "mv",
    path,
    output_dir
  ))
}

# Deleting ----------------------------------------------------------------

rap_delete_file <- function(path) {
  rlang::abort("Not implemented yet.")
}

# Helpers -----------------------------------------------------------------

run_dx <- function(arguments, call = rlang::caller_env()) {
  verify_dx(call = call)
  output <- processx::run(
    "dx",
    arguments
  )

  if (output$status) {
    rlang::abort(c("Error running dx command.", "i" = output$stderr))
  }

  output$stdout |>
    stringr::str_remove("\n$") |>
    stringr::str_split("\n") |>
    unlist()
}

verify_dx <- function(call = rlang::caller_env()) {
  verify_cli(
    program = "dx",
    error = "You need to be in the DNAnexus RAP environment to use this function.",
    call = call
  )
}
