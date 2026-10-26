# Shared, development-only documentation machinery. No package exports.
doc_sources <- function(root = ".") c(file.path(root, "README.md"),
  list.files(file.path(root, "vignettes"), "\\.Rmd$", full.names = TRUE))

read_doc_chunks <- function(path) {
  lines <- readLines(path, warn = FALSE)
  chunks <- list()
  i <- 1L
  while (i <= length(lines)) {
    if (grepl("^```(?:\\{r[ ,}]|r\\s*$)", lines[i], perl = TRUE)) {
      header <- lines[i]
      previous <- if (i > 1L) lines[i - 1L] else ""
      label <- if (grepl("^```r", header)) paste0("readme-", length(chunks) + 1L) else {
        trimws(sub("[,}].*$", "", sub("^```\\{r[ ,]*", "", header)))
      }
      if (!nzchar(label)) stop("Unlabeled R chunk: ", path, ":", i)
      start <- i + 1L
      i <- start
      while (i <= length(lines) && !grepl("^```\\s*$", lines[i])) i <- i + 1L
      if (i > length(lines)) stop("Unclosed R chunk: ", path)
      code <- if (i > start) paste(lines[start:(i - 1L)], collapse = "\n") else ""
      skip <- grepl("^<!-- documentation-skip: (installation|estimation) -->$", previous)
      expressions <- parse(text = code)
      call <- if (length(expressions) == 1L && is.call(expressions[[1]]))
        paste(deparse(expressions[[1]][[1]]), collapse = "") else ""
      plumbing <- (identical(label, "formatting") && call == "knitr::opts_chunk$set") ||
        call == "knitr::include_graphics"
      if (identical(label, "formatting") && plumbing) {
        defaults <- as.list(expressions[[1]])[-1L]
        for (name in intersect(names(defaults), c("eval", "purl", "include"))) {
          if (!identical(defaults[[name]], TRUE))
            stop("Formatting must not disable analysis defaults: ", name)
        }
      }
      options <- if (grepl("^```r", header)) "" else
        sub("}$", "", sub("^```\\{r[^,}]*,?\\s*", "", header))
      # alist preserves expressions without evaluating chunk options.
      options <- if (nzchar(options)) eval(parse(text = paste0("alist(", options, ")"))) else list()
      if (!is.null(options$purl) && !identical(options$purl, TRUE) && !plumbing)
        stop("Only formatting/image plumbing may disable purl: ", label)
      if (!is.null(options$include) && !identical(options$include, TRUE) && label != "formatting")
        stop("Analysis setup must be visible: ", label)
      if (!is.null(options$eval) && !identical(options$eval, TRUE) && !skip && !plumbing)
        stop("Analysis chunks must be evaluated: ", label)
      if (skip && !(startsWith(label, "estimate-") || basename(path) == "README.md"))
        stop("Only installation/estimation recipes may skip checks: ", label)
      chunks[[length(chunks) + 1L]] <- list(label = label, code = code,
        skip = skip || plumbing, header = header)
    }
    i <- i + 1L
  }
  labels <- vapply(chunks, `[[`, "", "label")
  if (anyDuplicated(labels)) stop("Duplicate chunk label in ", path)
  chunks
}

figure_recipes <- function() data.frame(
  article = c(rep("bsvarPost", 3), rep("inference-and-comparison", 2),
    rep("historical-decomposition-events", 2), rep("sign-restricted-workflows", 3)),
  chunk = c("fig-cdm", "fig-compare-cdm", "fig-representative", "fig-compare-irf",
    "fig-hypothesis", "fig-hd-overlay", "fig-hd-full", "fig-diagnostics",
    "fig-sign-hd-event", "fig-sign-hd-share"),
  figure = c("cdm-showcase.png", "compare-cdm-showcase.png", "representative-showcase.png",
    "compare-irf-showcase.png", "hypothesis-showcase.png", "hd-overlay-showcase.png",
    "hd-full-showcase.png", "diagnostics-showcase.png", "hd-event-showcase.png",
    "hd-event-share-showcase.png"),
  width = 8, height = c(4.5, 4.5, 4.5, 4.5, 4.5, 5, 5, 5, 6, 6),
  stringsAsFactors = FALSE)

evaluate_doc <- function(path, stop_at = NULL) {
  env <- new.env(parent = globalenv())
  for (chunk in read_doc_chunks(path)) {
    if (!chunk$skip) {
      tryCatch(eval(parse(text = chunk$code, keep.source = TRUE), envir = env),
        error = function(e) stop(basename(path), " [", chunk$label, "]: ",
          conditionMessage(e), call. = FALSE))
    }
    if (identical(chunk$label, stop_at)) break
  }
  env
}

check_demo_fixtures <- function(root = ".") {
  source_dir <- file.path(root, "inst/extdata")
  metadata <- utils::read.csv(file.path(source_dir, "demo-metadata.csv"))
  expected <- c("fiscal_post_bsvar.rds", "fiscal_post_bsvar_alt.rds", "sign_post.rds", "sign_post_alt.rds")
  stopifnot(identical(metadata$file, expected), all(metadata$draws == 200))
  for (i in seq_len(nrow(metadata))) {
    for (pair in list(c("file", "posterior_md5"), c("input", "input_md5"))) {
      name <- metadata[[pair[1]]][i]
      installed <- system.file("extdata", name, package = "bsvarPost", mustWork = TRUE)
      source <- file.path(source_dir, name)
      if (!file.exists(source) || unname(tools::md5sum(source)) != metadata[[pair[2]]][i] ||
          unname(tools::md5sum(installed)) != metadata[[pair[2]]][i])
        stop("Missing/stale demo asset: ", name, "; rebuild and reinstall the package")
    }
    post <- readRDS(system.file("extdata", metadata$file[i], package = "bsvarPost", mustWork = TRUE))
    stopifnot(dim(post$posterior$A)[3] == 200L)
    response <- bsvarPost::tidy_irf(post, horizon = 1)
    stopifnot(nrow(response) > 0, all(response$n_draws == 200L))
    if (i > 2L) {
      audit <- bsvarPost::restriction_audit(post, zero_tol = 1e-6)
      diagnostic <- bsvarPost::acceptance_diagnostics(post)
      stopifnot(nrow(audit) > 0L, nrow(diagnostic) > 0L,
        diagnostic$value[diagnostic$metric == "posterior_draws"] == 200L)
    }
  }
  invisible(TRUE)
}

figure_references <- function(path) {
  text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  basename(regmatches(text, gregexpr("figures/[A-Za-z0-9._-]+\\.(png|jpg|jpeg|svg)", text))[[1]])
}

check_figure_assets <- function(root = ".") {
  recipes <- figure_recipes()
  refs <- unique(unlist(lapply(doc_sources(root), figure_references)))
  if (!setequal(refs, recipes$figure)) stop("Unmapped or unused figure: ",
    paste(union(setdiff(refs, recipes$figure), setdiff(recipes$figure, refs)), collapse = ", "))
  files <- list.files(file.path(root, "vignettes/figures"), "\\.(png|jpg|jpeg|svg)$")
  if (!setequal(files, refs)) stop("Missing or unused figure asset: ",
    paste(union(setdiff(refs, files), setdiff(files, refs)), collapse = ", "))
  for (i in seq_len(nrow(recipes))) {
    r <- recipes[i, ]
    path <- file.path(root, "vignettes", paste0(r$article, ".Rmd"))
    chunks <- read_doc_chunks(path)
    if (!r$chunk %in% vapply(chunks, `[[`, "", "label") ||
        !r$figure %in% figure_references(path))
      stop("Missing figure recipe or reference: ", r$figure)
  }
  invisible(TRUE)
}

check_html_links <- function(directory, site = NULL) {
  if (!requireNamespace("xml2", quietly = TRUE)) stop("HTML QA requires xml2 (a pkgdown dependency)")
  files <- list.files(directory, "\\.html$", full.names = TRUE, recursive = TRUE)
  if (!length(files)) stop("No HTML files to validate: ", directory)
  for (file in files) {
    html <- xml2::read_html(file)
    links <- unique(c(xml2::xml_attr(xml2::xml_find_all(html, "//*[@href]"), "href"),
      xml2::xml_attr(xml2::xml_find_all(html, "//*[@src]"), "src")))
    for (link in links[!is.na(links) & nzchar(links)]) {
      canonical <- startsWith(link, "https://davidzenz.github.io/bsvarPost/")
      if (canonical && !is.null(site)) {
        link <- substring(link, nchar("https://davidzenz.github.io/bsvarPost/") + 1L)
        base <- site
        if (!nzchar(sub("[?#].*$", "", link))) link <- paste0("index.html", link)
      } else {
        if (grepl("^([A-Za-z][A-Za-z0-9+.-]*:|//)", link)) next
        base <- dirname(file)
      }
      fragment <- if (grepl("#", link, fixed = TRUE)) sub("^[^#]*#", "", link) else ""
      path <- utils::URLdecode(sub("[?#].*$", "", link))
      # R's installed package index links to the global R help tree, which is
      # provided by R rather than this package (and may not exist in a staged lib).
      if (basename(file) == "index.html" && grepl("^(\\.\\./)+doc/html/", path)) next
      target <- if (!nzchar(path)) file else file.path(base, path)
      if (dir.exists(target)) target <- file.path(target, "index.html")
      if (!file.exists(target)) stop("Broken local link in ", file, ": ", link)
      if (nzchar(fragment) && grepl("\\.html$", target)) {
        target_html <- if (identical(target, file)) html else xml2::read_html(target)
        ids <- c(xml2::xml_attr(xml2::xml_find_all(target_html, "//*[@id]"), "id"),
          xml2::xml_attr(xml2::xml_find_all(target_html, "//a[@name]"), "name"))
        if (!utils::URLdecode(fragment) %in% ids) stop("Broken fragment in ", file, ": ", link)
      }
    }
  }
  invisible(TRUE)
}
