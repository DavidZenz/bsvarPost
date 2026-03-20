release_qa_check <- function(root = ".") {
  namespace_lines <- readLines(file.path(root, "NAMESPACE"), warn = FALSE)
  exports <- sub("^export\\((.*)\\)$", "\\1", grep("^export\\(", namespace_lines, value = TRUE))
  s3_lines <- grep("^S3method\\(", namespace_lines, value = TRUE)
  s3_parts <- regmatches(s3_lines, regexec("^S3method\\(([^,]+),(.+)\\)$", s3_lines))
  s3_methods <- lapply(s3_parts, function(x) list(generic = x[[2]], class = x[[3]]))

  man_files <- list.files(file.path(root, "man"), pattern = "\\.Rd$", full.names = TRUE)
  aliases <- unique(unlist(lapply(man_files, function(path) {
    lines <- readLines(path, warn = FALSE)
    sub("^\\\\alias\\{(.*)\\}$", "\\1", grep("^\\\\alias\\{", lines, value = TRUE))
  })))

  test_files <- list.files(file.path(root, "inst", "tinytest"), pattern = "^test_.*\\.R$", full.names = TRUE)
  test_contents <- lapply(test_files, readLines, warn = FALSE)
  names(test_contents) <- basename(test_files)

  missing_docs <- exports[!exports %in% aliases]
  uncovered_exports <- exports[!vapply(exports, function(fn) {
    any(vapply(test_contents, function(lines) any(grepl(paste0("\\b", fn, "\\b"), lines)), logical(1)))
  }, logical(1))]

  ns_env <- if ("bsvarPost" %in% loadedNamespaces()) {
    asNamespace("bsvarPost")
  } else {
    env <- new.env(parent = baseenv())
    for (path in list.files(file.path(root, "R"), pattern = "\\.[Rr]$", full.names = TRUE)) {
      sys.source(path, envir = env)
    }
    env
  }
  missing_export_defs <- exports[!vapply(exports, exists, logical(1), envir = ns_env, inherits = FALSE)]
  missing_s3 <- vapply(s3_methods, function(entry) {
    !exists(paste0(entry$generic, ".", entry$class), envir = ns_env, inherits = FALSE)
  }, logical(1))

  pkgdown_lines <- readLines(file.path(root, "_pkgdown.yml"), warn = FALSE)
  vignette_files <- list.files(file.path(root, "vignettes"), pattern = "\\.[Rr]md$", full.names = FALSE)
  vignette_names <- sub("\\.[Rr]md$", "", vignette_files)
  article_section_start <- grep("^articles:\\s*$", pkgdown_lines)
  article_lines <- if (length(article_section_start)) pkgdown_lines[article_section_start[1]:length(pkgdown_lines)] else character()
  article_entries <- unique(sub("^\\s*-\\s+", "", grep("^\\s*-\\s+[A-Za-z0-9._-]+\\s*$", article_lines, value = TRUE)))
  article_entries <- setdiff(article_entries, c("title: Articles", "navbar: Articles", "contents:"))
  missing_articles <- setdiff(vignette_names, article_entries)

  figure_files <- list.files(file.path(root, "vignettes", "figures"), pattern = "\\.(png|jpg|jpeg|svg)$",
                             full.names = FALSE, ignore.case = TRUE)
  figure_ref_files <- c(file.path(root, "README.md"), list.files(file.path(root, "vignettes"),
                                                                 pattern = "\\.[Rr]md$", full.names = TRUE))
  figure_refs <- unique(unlist(lapply(figure_ref_files, function(path) {
    lines <- readLines(path, warn = FALSE)
    matches <- regmatches(lines, gregexpr("figures/[A-Za-z0-9._-]+\\.(png|jpg|jpeg|svg)", lines, perl = TRUE))
    basename(unlist(matches, use.names = FALSE))
  })))
  figure_refs <- sort(unique(figure_refs[nzchar(figure_refs)]))
  missing_figures <- setdiff(figure_refs, figure_files)
  unused_figures <- setdiff(figure_files, figure_refs)

  failures <- character()
  if (length(missing_docs)) {
    failures <- c(failures, paste("Missing Rd aliases for exports:", paste(sort(missing_docs), collapse = ", ")))
  }
  if (length(uncovered_exports)) {
    failures <- c(failures, paste("Missing direct tinytest coverage for exports:", paste(sort(uncovered_exports), collapse = ", ")))
  }
  if (length(missing_export_defs)) {
    failures <- c(failures, paste("Missing export definitions in namespace:", paste(sort(missing_export_defs), collapse = ", ")))
  }
  if (any(missing_s3)) {
    missing_labels <- vapply(s3_methods[missing_s3], function(entry) paste0(entry$generic, ".", entry$class), character(1))
    failures <- c(failures, paste("Missing registered S3 methods:", paste(sort(missing_labels), collapse = ", ")))
  }
  if (length(missing_articles)) {
    failures <- c(failures, paste("Vignettes missing from _pkgdown.yml articles index:", paste(sort(missing_articles), collapse = ", ")))
  }
  if (length(missing_figures)) {
    failures <- c(failures, paste("Referenced vignette figures are missing:", paste(sort(missing_figures), collapse = ", ")))
  }
  if (length(unused_figures)) {
    failures <- c(failures, paste("Unreferenced pre-rendered vignette figures are tracked:", paste(sort(unused_figures), collapse = ", ")))
  }

  if (length(failures)) {
    stop(paste(failures, collapse = "\n"), call. = FALSE)
  }

  invisible(TRUE)
}
