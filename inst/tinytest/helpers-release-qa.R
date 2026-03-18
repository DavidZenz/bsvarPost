installed_release_qa_check <- function(pkg = "bsvarPost") {
  ns <- asNamespace(pkg)
  namespace_path <- system.file("NAMESPACE", package = pkg)
  if (!nzchar(namespace_path)) {
    stop("Installed package is missing NAMESPACE.", call. = FALSE)
  }

  namespace_lines <- readLines(namespace_path, warn = FALSE)
  exports <- sub("^export\\((.*)\\)$", "\\1", grep("^export\\(", namespace_lines, value = TRUE))
  s3_lines <- grep("^S3method\\(", namespace_lines, value = TRUE)
  s3_parts <- regmatches(s3_lines, regexec("^S3method\\(([^,]+),(.+)\\)$", s3_lines))
  s3_methods <- lapply(s3_parts, function(x) list(generic = x[[2]], class = x[[3]]))

  missing_export_defs <- exports[!vapply(exports, exists, logical(1), envir = ns, inherits = FALSE)]
  missing_s3 <- vapply(s3_methods, function(entry) {
    !exists(paste0(entry$generic, ".", entry$class), envir = ns, inherits = FALSE)
  }, logical(1))

  failures <- character()
  if (length(missing_export_defs)) {
    failures <- c(failures, paste("Missing installed export definitions:", paste(sort(missing_export_defs), collapse = ", ")))
  }
  if (any(missing_s3)) {
    missing_labels <- vapply(s3_methods[missing_s3], function(entry) paste0(entry$generic, ".", entry$class), character(1))
    failures <- c(failures, paste("Missing installed S3 methods:", paste(sort(missing_labels), collapse = ", ")))
  }

  if (length(failures)) {
    stop(paste(failures, collapse = "\n"), call. = FALSE)
  }

  invisible(TRUE)
}
