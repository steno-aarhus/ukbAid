# Get ---------------------------------------------------------------------

#' Get the username of the user who is working within the RAP RStudio session.
#'
#' @return Character vector with users username within the RAP session.
#' @export
#'
rap_get_user <- function() {
  run_dx("whoami")
}

#' @describeIn rap_get_user Deprecated function. Use `rap_get_user()` instead.
#' @export
get_username <- function() {
  lifecycle::deprecate_soft(
    when = "0.1.0",
    what = "get_username()",
    with = "rap_get_user()"
  )
  rap_get_user()
}

#' Get the paths of all the users within the RAP project server.
#'
#' @return Character vector of folder paths.
#' @export
#'
rap_get_path_users <- function() {
  rap_get_path_files("users/")
}

#' Get the path of a single user within the RAP project server.
#'
#' @param user A user's username.
#'
#' @return A character scalar of one users path.
#' @export
#'
rap_get_path_user <- function(user) {
  users <- rap_get_path_users()
  user <- rlang::arg_match(
    user,
    stringr::str_remove(users, "/$")
  )

  users |>
    stringr::str_subset(user)
}

#' Title
#'
#' @param path
#'
#' @return
#' @export
#'
#' @examples
rap_get_path_files <- function(path) {
  run_dx(c("ls", "--all", path)) |>
    stringr::str_subset("^\\.\\.?/$", negate = TRUE)
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

# Copying -----------------------------------------------------------------

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
  run_dx(c("download", rap_path, "--output", local_path,
           "--overwrite", "--no-progress", "--lightweight"))
  local_path
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
