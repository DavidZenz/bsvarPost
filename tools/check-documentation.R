# Run from the checkout root after building/installing vignettes. README and
# each installed script get their own R session and
# temporary working directory, with only the installed package's demo assets.
args <- commandArgs(trailingOnly = TRUE)
value <- function(prefix) {
  x <- args[startsWith(args, prefix)]
  if (length(x)) substring(x[1], nchar(prefix) + 1L) else NULL
}
root <- value("--root=")
if (is.null(root)) root <- "."
root <- normalizePath(root, mustWork = TRUE)
source(file.path(root, "tools/doc-helpers.R"))

check_results <- function(env) {
  objects <- mget(ls(env), envir = env)
  stopifnot(any(vapply(objects, inherits, logical(1), "bsvar_post_tbl")))
  for (object in objects) {
    if (inherits(object, "bsvar_post_tbl")) stopifnot(nrow(object) > 0L)
    if (inherits(object, "ggplot")) ggplot2::ggplot_build(object)
    if (inherits(object, "grob")) grid::grid.draw(object)
  }
  invisible(TRUE)
}

worker <- value("--worker=")
script <- value("--script=")
if (!is.null(worker) || !is.null(script)) {
  scratch <- tempfile("doc-session-")
  dir.create(scratch)
  setwd(scratch)
  grDevices::pdf(file.path(scratch, "plots.pdf"))
  if (!is.null(worker)) {
    env <- evaluate_doc(worker)
    check_results(env)
  } else {
    env <- new.env(parent = globalenv())
    sys.source(script, envir = env)
    check_results(env)
  }
  grDevices::dev.off()
  message("PASS ", basename(if (is.null(worker)) script else worker))
} else {
  if (any(file.exists(file.path(root, c("index.md", "pkgdown/index.md")))))
    stop("README.md must remain the canonical homepage; remove overriding index.md")
  check_demo_fixtures(root)
  if (!"--fixtures-only" %in% args) {
    check_figure_assets(root)
    # Rendering checks the articles; here verify their inclusion policy without
    # executing them again. Installed scripts provide the fresh-session smoke.
    invisible(lapply(doc_sources(root), read_doc_chunks))
    checker <- file.path(root, "tools/check-documentation.R")
    run_child <- function(flag, path) {
      status <- system2(file.path(R.home("bin"), "Rscript"), c("--vanilla", shQuote(checker),
        shQuote(paste0("--root=", root)), shQuote(paste0(flag, normalizePath(path)))))
      if (status != 0) stop("Documentation execution failed: ", path)
    }
    run_child("--worker=", file.path(root, "README.md"))
    site <- value("--site=")
    if (!is.null(site)) {
      site <- normalizePath(site, mustWork = TRUE)
      check_html_links(site, site = site)
    }
    if ("--installed-docs" %in% args) {
      docs <- system.file("doc", package = "bsvarPost", mustWork = TRUE)
      check_html_links(docs, site = site)
      scripts <- list.files(docs, "\\.R$", full.names = TRUE)
      expected <- sub("\\.Rmd$", ".R", basename(doc_sources(root)[-1]))
      stopifnot(setequal(basename(scripts), expected))
      for (path in scripts) run_child("--script=", path)
    }
  }
  message("Documentation QA passed")
}
