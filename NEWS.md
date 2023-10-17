# ukbAid 0.0.16

-   Make use of either names or titles for the
    `dx run app-table-exporter` command in `create_csv_from_database()`.
-   Set cli package to exactly the version needed (\> 3.6.0), to help
    deal with a bug in how pak installs packages.
-   Switch `setup_ukb_rap()` function so it doesn't install packages.
    Instead, install ukbAid directly in the first step.

# ukbAid 0.0.15

-   Starting to use NEWS.
