
#' Add your name and email to Git's config settings.
#'
#' @param name Your full name, for instance "Luke W. Johnston".
#' @param email Your most commonly used email.
#'
#' @return Tibble with changed config settings. Also has side effect of
#'   modifying the user.name and user.email settings in Git.
#' @export
#'
setup_git_config <- function(name, email) {
    gert::git_config_global_set("user.name", name)
    gert::git_config_global_set("user.email", email)
    cli::cli_alert_success("Git config has been set, see output below")
    gert::git_config_global() %>%
        dplyr::filter(name %in% c("user.name", "user.email")) %>%
        dplyr::select(name, value)
}

#' Get the local (not in the UKB RAP) RStudio configuration settings as a character vector.
#'
#' @return Character string of local config settings.
#' @noRd
#'
#' @examples
#' get_rstudio_config_as_text() %>%
#'   clipr::write_clip()
get_rstudio_config_as_text <- function() {
    usethis:::rstudio_config_path() %>%
        fs::dir_ls(regexp = "rstudio-prefs") %>%
        rjson::fromJSON(file = .) %>%
        dput() %>%
        utils::capture.output()
}

#' Set basic configurations at the start of each new session in the UKB RAP.
#'
#' @return NULL. The function is used for its side effects.
#'
setup_rstudio_luke <- function() {
    # Use this code to paste config settings here
    # get_rstudio_config_as_text() %>%
    #     clipr::write_clip()

    rstudio_preferences <- list(
        initial_working_directory = "~",
        highlight_selected_line = TRUE,
        scroll_past_end_of_document = TRUE,
        highlight_r_function_calls = TRUE,
        rainbow_parentheses = TRUE,
        auto_append_newline = TRUE,
        strip_trailing_whitespace = TRUE,
        auto_save_on_blur = TRUE,
        check_unexpected_assignment_in_function_call = TRUE,
        warn_if_no_such_variable_in_scope = TRUE,
        style_diagnostics = TRUE,
        editor_keybindings = "vim",
        syntax_color_console = TRUE,
        posix_terminal_shell = "bash",
        font_size_points = 12,
        panes = list(
            quadrants = c("Source", "TabSet1", "Console", "TabSet2"),
            tabSet1 = c("Packages", "VCS", "Presentation"),
            tabSet2 = c(
                "Environment",
                "History",
                "Files",
                "Plots",
                "Help",
                "Build",
                "Viewer",
                "Presentations"
            ),
            hiddenTabSet = c("Connections", "Tutorial"),
            console_left_on_top = FALSE,
            console_right_on_top = TRUE,
            additional_source_columns = 0
        ),
        show_doc_outline_rmd = TRUE,
        show_rmd_render_command = TRUE,
        doc_outline_show = "all",
        default_sweave_engine = "knitr",
        use_tinytex = TRUE,
        show_panel_focus_rectangle = TRUE,
        restore_source_documents = FALSE,
        save_workspace = "never",
        load_workspace = FALSE,
        restore_last_project = FALSE,
        jobs_tab_visibility = "shown",
        num_spaces_for_tab = 4,
        default_encoding = "UTF-8",
        save_files_before_build = TRUE,
        always_save_history = FALSE,
        rmd_viewer_type = "pane",
        editor_theme = "Chrome",
        quarto_enabled = "enabled",
        new_proj_git_init = TRUE,
        new_proj_use_renv = TRUE
    )

    rstudio_preferences %>%
        purrr::iwalk(~rstudioapi::writeRStudioPreference(.y, .x))
    cli::cli_alert_success("Set the RStudio preferences.")

    setup_git_config("Luke W. Johnston", "lwjohnst@gmail.com")
    cli::cli_alert_success("Set the Git config settings for user name and email.")

    clipr::write_clip("if (interactive()) {
        suppressMessages(require(devtools))
        suppressMessages(require(usethis))
        suppressMessages(require(gert))
    }")
    cli::cli_alert_info("Copied some basic settings to be pasted into {.path .Rprofile}.")
    usethis::edit_r_profile(scope = "user")
    return(invisible(NULL))
}

