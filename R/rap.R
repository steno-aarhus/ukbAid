# Get ---------------------------------------------------------------------


#' Get the username of the user who is working within the RAP RStudio session.
#'
#' @return Character vector with users username within the RAP session.
#' @export
#'
rap_get_user <- function() {
  run_dx("dx whoami")
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
  run_dx("dx ls --all users/")
}

rap_get_path_user <- function(user) {
  rap_get_path_users() |>
    stringr::str_subset(user)
}

rap_get_path_files <- function(path) {
  glue::glue("dx ls --all {path}") |>
    run_dx()
}

rap_get_path_database()

rap_get_path_schema <- function() {
  rap_get_path_files(".") |>
    stringr::str_subset("\\.json\\.gz")
}

rap_copy_to <- function(local_path, rap_path) {
  glue::glue("dx upload {local_path} --destination {rap_path}") |>
    run_dx()
}


rap_copy_from <- function(rap_path, local_path) {
  glue::glue("dx get {rap_path} --output {local_path} --overwrite") |>
    run_dx()
}
rap_delete_file(path)

# Helpers -----------------------------------------------------------------

run_dx <- function(command, call = rlang::caller_env()) {
  verify_dx(call = call)
  run_cli(command)
}

verify_dx <- function(call = rlang::caller_env()) {
  verify_cli(
    program = "dx",
    error = "You need to be in the DNAnexus RAP environment to use this function.",
    call = call
  )
}
