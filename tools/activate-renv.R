project <- normalizePath(file.path(getwd()), winslash = "/", mustWork = FALSE)

Sys.setenv(
  RENV_PATHS_ROOT = file.path(project, ".renv"),
  RENV_PATHS_LIBRARY_ROOT = file.path(project, ".renv", "library"),
  RENV_CONFIG_PPM_ENABLED = "TRUE"
)

options(repos = c(PPM = "https://packagemanager.posit.co/cran/latest"))

source("renv/activate.R")

cat("renv activated for", project, "\n")
