
#' Converts the protocol md or Rmd file into a Word document with relevant theme and settings.
#'
#' @param toc Include a table of contents?
#' @param toc_depth If a toc is included, how many heading levels should be shown?
#' @param fig_width The default width of the figures.
#' @param fig_height The default height of the figures.
#'
#' @return Outputs a Word document for the protocol.
#' @export
#'
protocol_document <- function(toc = FALSE, toc_depth = 3, fig_width = 5, fig_height = 4) {
    word_template <- fs::path_package("ukbAid", "templates", "protocol", "resources", "template.docx")
    csl_template <- fs::path_package("ukbAid", "templates", "protocol", "resources", "vancouver.csl")

    rmarkdown::word_document(
        toc = toc,
        toc_depth = toc_depth,
        fig_width = fig_width,
        fig_height = fig_height,
        reference_docx = word_template,
        pandoc_args = c("--csl=", csl_template)
    )
}
