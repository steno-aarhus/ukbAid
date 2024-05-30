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

rap_get_path_users <- function() {
  rap_get_path_files("users/")
}

rap_get_path_user <- function(user) {
  rap_get_path_users() |>
    stringr::str_subset(user)
}

rap_get_path_files <- function(path) {
  run_dx(c("ls", "--all", path)) |>
    stringr::str_remove("^\\.\\.?/$")
}

rap_get_path_database <- function() {
  rap_get_path_files(".") |>
    stringr::str_subset("\\.dataset$")
}

rap_get_path_schema <- function() {
  rap_get_path_files(".") |>
    stringr::str_subset("\\.json\\.gz")
}

# Copying -----------------------------------------------------------------

rap_copy_to <- function(local_path, rap_path) {
  run_dx(c("upload", local_path, "--destination", rap_path))
}


rap_copy_from <- function(rap_path, local_path) {
  run_dx(c("get", rap_path, "--output", local_path, "--overwrite"))
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
