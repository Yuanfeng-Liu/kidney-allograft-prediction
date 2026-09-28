# Run from the repository root. Installs missing Shiny application dependencies.
# Original package versions were not recorded in a lockfile.
if (getRversion() < "4.1.0") {
  stop("R 4.1 or later is required for the native pipe syntax used by this application.")
}
packages <- c(
  "shiny", "bslib", "shinydashboard", "shinyjs", "DT", "shinyBS",
  "emayili", "dplyr", "glue", "stringr", "httr", "jsonlite", "commonmark",
  "shinyWidgets", "xgboost", "caret", "ranger"
)
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
}
message("Dependencies checked. Start the app with shiny::runApp('shinyapp').")
