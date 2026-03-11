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

  if (length(failures)) {
    stop(paste(failures, collapse = "\n"), call. = FALSE)
  }

  invisible(TRUE)
}
