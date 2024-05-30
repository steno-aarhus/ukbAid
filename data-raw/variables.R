devtools::load_all()

rap_get_path_schema() |>
  rap_copy_from("data-raw/schema.json.gz") |>
  R.utils::gunzip(overwrite = TRUE)

fields <- jsonlite::read_json("data-raw/schema.json")$model$entities$participant$fields %>%
  unname()

rap_variables <- tibble::tibble(
  id = purrr::map_chr(fields, "name"),
  title = purrr::map_chr(fields, "title")
)

usethis::use_data(rap_variables, overwrite = TRUE, version = 3)

