
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
