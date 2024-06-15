
# Metadata extraction -----------------------------------------------------

#' Extract author metadata from a Rmd or qmd file.
#'
#' @param path The path to the file.
#'
#' @return A list with author details.
#' @keywords internal
#'
#' @examples
#' fs::path_package("ukbAid", "examples", "protocol.qmd") |>
#'  zen_get_file_metadata_authors()
zen_get_file_metadata_authors <- function(path) {
  rmarkdown::yaml_front_matter(path)$author |>
    purrr::map(~ list(
      name = .x$name,
      affiliation = unlist(.x$affiliations)[[1]],
      orcid = .x$orcid
    )) |>
    purrr::map_depth(1, ~ purrr::discard(.x, is.null))
}

#' Get the URL of the GitHub repository.
#'
#' @return A list.
#' @keywords internal
#'
#' @examples
#' zen_get_project_github_url()
zen_get_project_github_url <- function() {
  url <- gert::git_remote_list() |>
    dplyr::filter(.data$name == "origin") |>
    dplyr::pull(url) |>
    stringr::str_remove("\\.git$")
  list(
    identifier = url,
    relation = "isPartOf"
  )
}

#' Create the metadata for Zenodo based on the Rmd or qmd protocol file.
#'
#' @param path The path to the protocol file.
#'
#' @return A list of metadata.
#' @export
#'
#' @examples
#' fs::path_package("ukbAid", "examples", "protocol.qmd") |>
#'   zen_create_protocol_metadata()
zen_create_protocol_metadata <- function(path) {
  list(
    # Take title from the YAML header of the protocols file.
    title = rmarkdown::yaml_front_matter(path)$title,
    creator = zen_get_file_metadata_authors(path),
    accessRights = "open",
    format = "publication",
    description = glue::glue("Protocol for research project using UK Biobank. {ukbAid::statements$protocol}"),
    isPartOf = list(zen_get_project_github_url())
  )
}

# Protocol specific -------------------------------------------------------

#' Create a PDF of the protocol Rmd or qmd file.
#'
#' @param path The path to the protocol file.
#'
#' @return Character vector of the created pdf file, used for side effect of
#'   creating a PDF.
#' @export
#'
zen_create_protocol_pdf <- function(path) {
  if (!fs::file_exists(path)) {
    cli::cli_abort("The file path {.val {path}} doesn't exist. Is there a typo?")
  }
  withr::with_dir(
    fs::path_dir(path),
    {
      quarto::quarto_render(
        input = fs::path_file(path),
        output_format = "pdf"
      )
    }
  )
  return(fs::path_ext_set(path, "pdf"))
}

# Uploading to Zenodo -----------------------------------------------------

#' Store the token for Zenodo.
#'
#' @return A character vector of the token used by Zenodo.
#' @export
#'
zen_get_token <- function() {
  askpass::askpass("Please paste in either the Zenodo Sandbox token or the normal Zenodo token.")
}

#' Create a record for a file on Zenodo.
#'
#' @param path The path to the file to upload.
#' @param metadata The metadata necessary for Zenodo to create a deposit record.
#' @param token The token for Zenodo, via [zen_get_token()].
#' @param sandbox Whether to test the upload on the sandbox first. Strongly recommended.
#'
#' @return Nothing, used for the side effect of creating a record on Zenodo.
#' @export
#'
zen_create_file_record <- function(path, metadata, token, sandbox = TRUE) {
  if (sandbox) {
    Sys.setenv("ZENODO_SANDBOX_TOKEN" = token)
  } else {
    Sys.setenv("ZENODO_TOKEN" = token)
  }
  client <- deposits::depositsClient$new(
    service = "zenodo",
    sandbox = TRUE,
    metadata = metadata
  )
  client$deposit_new()
  client$deposit_upload_file(path, overwrite = TRUE)
}

