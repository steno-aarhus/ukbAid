library(deposits)

dcmi_terms()

# authors <-


protocol_path <- here::here("data-raw/protocol.qmd")

quarto::quarto_render(
  input = protocol_path,
  output_format = "pdf"
)

author_metadata <- rmarkdown::yaml_front_matter(protocol_path)$author |>
  purrr::map(~list(
    name = .x$name,
    affiliation = unlist(.x$affiliations)[[1]],
    orcid = .x$orcid
  )) |>
  purrr::map_depth(1, ~purrr::discard(.x, is.null))

metadata <- list(
  # Take title from the YAML header of the protocols file.
  title = rmarkdown::yaml_front_matter(here::here("data-raw/protocol.qmd"))$title,
  # creator = list(authors)
  creator = list(author_metadata),
  abstract = "",
  accessRights = "open",
  # created = lubridate::today(),
  format = "publication"
)

Sys.setenv("ZENODO_SANDBOX_TOKEN" = askpass::askpass("Please paste in your Zenodo Token."))
# Sys.setenv("ZENODO_TOKEN" = askpass::askpass("Please paste in your Zenodo Token."))

client <- depositsClient$new(
  service = "zenodo",
  sandbox = TRUE
)

filename <- tempfile(fileext = ".json")
deposits_metadata_template("test.json")
# then edit that file to complete metadata

files <- jsonlite::fromJSON(system("dx find data --class file --path users/ --json", intern = TRUE), flatten = TRUE)
lubridate::as_datetime(files$describe.modified)
