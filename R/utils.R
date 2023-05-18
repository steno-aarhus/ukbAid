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

build_website <- function() {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    rlang::abort("Please install Quarto to use this function.")
  }

  withr::with_dir(
    new = fs::path_package("vignettes", package = "ukbAid"),
    {quarto::quarto_render()}
  )
  # pkgdown::init_site()
  # pkgdown::build_home()
  # pkgdown::build_reference()
  # pkgdown::build_news()
}


