## code to prepare `statements` dataset goes here

statements <- list(
  protocol = "This research will use the UK Biobank Resource under Application Number 81520.",
  paper = "This research has been conducted using the UK Biobank Resource under Application Number 81520."
)

usethis::use_data(statements, overwrite = TRUE, version = 3)
