library(deposits)

protocol_path <- here::here("dev/protocol.qmd")

zen_create_protocol_pdf <- function(path) {
  if (!fs::file_exists(path)) {
    cli::cli_abort("The file path {.val {path}} doesn't exist. Is there a typo?")
  }
  withr::with_dir(
    fs::path_dir(path),
    {
      quarto::quarto_render(
        input = fs::path_file(protocol_path),
        output_format = "pdf"
      )
    }
  )
}

zen_get_file_metadata_authors <- function(path) {
  rmarkdown::yaml_front_matter(path)$author |>
    purrr::map(~ list(
      name = .x$name,
      affiliation = unlist(.x$affiliations)[[1]],
      orcid = .x$orcid
    )) |>
    purrr::map_depth(1, ~ purrr::discard(.x, is.null))
}

zen_get_project_github_url <- function() {
  gert::git_remote_list() |>
    dplyr::filter(.data$name == "origin") |>
    dplyr::pull(url) |>
    stringr::str_remove("\\.git$")
}

zen_create_protocol_metadata <- function(path) {
  list(
    # Take title from the YAML header of the protocols file.
    title = rmarkdown::yaml_front_matter(path)$title,
    creator = zen_get_file_metadata_authors(path),
    accessRights = "open",
    format = "publication",
    description = glue::glue("Protocol for research project using UK Biobank. {statements$protocol}"),
    isPartOf = zen_get_project_github_url()
  )
}


zen_get_token <- function() {
  askpass::askpass("Please paste in either the Zenodo Sandbox ")
}

zen_create_file_record <- function(path, metadata, token) {
  Sys.setenv("ZENODO_SANDBOX_TOKEN" = token)
# Sys.setenv("ZENODO_TOKEN" = askpass::askpass("Please paste in your Zenodo Token."))
  client <- deposits::depositsClient$new(
    service = "zenodo",
    sandbox = TRUE,
    metadata = metadata
  )
  client$deposit_new()
  client$deposit_upload_file(path, overwrite = TRUE)
}

client <- zen_create_record(

)

metadata <- zen_create_protocol_metadata(protocol_path)

client$deposit_fill_metadata(metadata)

client$deposit_add_resource("dev/test-2.json")

filename <- tempfile(fileext = ".json")
deposits_metadata_template("dev/test.json")
# then edit that file to complete metadata
