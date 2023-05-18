# TODO: Write your project abbreviated title and full title here.

TODO: Give a brief description of what your project is about

This project...

# Installing and setting up the project

If dependencies have been managed by using
`usethis::use_package("packagename")` through the `DESCRIPTION` file,
installing dependencies is as easy as opening the `.Rproj` file and
running this command in the console:

``` r
pak::pak()
```

Once you've created your dataset using `data-raw/create-data.R`, you can
uncomment the lines in the `_targets.R` file and afterwards run this
code whenever you enter the RAP project.

``` r
targets::tar_make()
```

# Brief description of folder and file contents

The following folders contain:

-   `data/`: Will contain the UK Biobank data (not saved to Git) as well
    as the intermediate results output files.

-   `data-raw/`: Contains the R script to download the data, as well as
    the CSV files that contain the project variables and the variable
    list as named in the RAP.

-   `doc/`: This file contains the R Markdown, Word, or other types of
    documents with written content, like the manuscript and protocol.

-   `R/`: Contains the R scripts and functions to create the figures,
    tables, and results for the project.

