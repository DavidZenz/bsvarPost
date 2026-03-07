source("tools/activate-renv.R")

cat("pkgType:", getOption("pkgType"), "\n")
renv::restore(prompt = FALSE)
