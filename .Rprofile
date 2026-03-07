local({
  project <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)

  # Keep renv fully project-local in this workspace.
  Sys.setenv(
    RENV_PATHS_ROOT = file.path(project, ".renv"),
    RENV_PATHS_LIBRARY_ROOT = file.path(project, ".renv", "library"),
    RENV_CONFIG_PPM_ENABLED = "TRUE"
  )

  # Prefer Posit Package Manager for reproducible restores.
  options(repos = c(PPM = "https://packagemanager.posit.co/cran/latest"))
})
