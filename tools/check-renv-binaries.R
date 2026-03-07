pkg_type <- getOption("pkgType")
repos <- getOption("repos")

cat("pkgType:", pkg_type, "\n")
cat("repos:\n")
print(repos)

if (identical(pkg_type, "source")) {
  message(
    "This R installation is source-only. Posit Package Manager can still be used ",
    "as the repository, but precompiled binaries will not be selected by this interpreter."
  )
} else {
  message("This R installation supports binary package installs.")
}
