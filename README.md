
# ukbAid: Aid in doing analyses on the UK Biobank RAP

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of ukbAid is to help our research group at Steno Diabetes Center Aarhus
that is working on the UK Biobank on the RAP.

## Installation

You can install the development version of ukbAid inside RStudio in the R Console like so:

``` r
# If remotes package isn't installed, first install with (without the `#` comment):
# install.packages("remotes")
remotes::install_github("steno-aarhus/ukbAid")
```

## Using ukbAid

Assumptions:

- Each user has their own user folder inside `users/`, based on their user name
given by the RAP.
- Each project is a `.tar.gz` file within the users own main folder, for
instance `users/lwjohnst/ecc-cmd-ukb.tar.gz`. The way the RAP system works is
that each project is backed up and restored into the clean RStudio analysis
workspace.

### For general users

This is INCOMPLETE!

``` r
# Steps outside UKB RAP:
ukbAid::setup_git_config("Luke W. Johnston", "lwjohnst@gmail.com")
ukbAid::setup_ukb_project("~/Desktop/project-name-abbreviation")

# Steps inside UKB RAP:
ukbAid::setup_git_config("Luke W. Johnston", "lwjohnst@gmail.com")
# First time using UKB RAP with project
ukbAid::download_ukb_project("GITHUB/REPO")
# usethis::create_from_github()
# Open up the newly created project
source(here::here("data-raw/download-variables.R"))
```

<!-- Add instructions on saying what other packages to include in project using, like renv -->

### For admin users

This is code used only by the admins.

``` r
ukbAid:::import_clean_and_upload_database_variables()
```

