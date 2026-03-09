#' Export bsvarPost tables as reporting objects
#'
#' These helpers target the package's tidy tabular outputs, especially
#' `bsvar_post_tbl` objects returned by the extraction, comparison, hypothesis,
#' audit, and summary helpers.
#'
#' @param x A `bsvar_post_tbl` or data frame.
#' @param ... Additional arguments passed to the backend formatter.
#' @name reporting
NULL

#' @rdname reporting
#' @param caption Optional table caption.
#' @param digits Optional number of digits used to round numeric columns before
#'   rendering.
#' @export
as_kable <- function(x, ...) {
  UseMethod("as_kable")
}

#' @rdname reporting
#' @export
as_kable.bsvar_post_tbl <- function(x, caption = NULL, digits = NULL, ...) {
  report_table <- prepare_report_table(x, digits = digits)
  knitr::kable(report_table, caption = caption, ...)
}

#' @rdname reporting
#' @export
as_kable.data.frame <- function(x, caption = NULL, digits = NULL, ...) {
  report_table <- prepare_report_table(x, digits = digits)
  knitr::kable(report_table, caption = caption, ...)
}

#' @rdname reporting
#' @export
as_kable.default <- function(x, ...) {
  stop("`as_kable()` supports bsvarPost tables and data frames only.", call. = FALSE)
}

#' @rdname reporting
#' @export
as_gt <- function(x, ...) {
  UseMethod("as_gt")
}

#' @rdname reporting
#' @export
as_gt.bsvar_post_tbl <- function(x, caption = NULL, digits = NULL, ...) {
  ensure_namespace("gt", "as_gt()")
  report_table <- prepare_report_table(x, digits = digits)
  out <- gt::gt(report_table, ...)
  if (!is.null(caption)) {
    out <- gt::tab_header(out, title = caption)
  }
  out
}

#' @rdname reporting
#' @export
as_gt.data.frame <- function(x, caption = NULL, digits = NULL, ...) {
  ensure_namespace("gt", "as_gt()")
  report_table <- prepare_report_table(x, digits = digits)
  out <- gt::gt(report_table, ...)
  if (!is.null(caption)) {
    out <- gt::tab_header(out, title = caption)
  }
  out
}

#' @rdname reporting
#' @export
as_gt.default <- function(x, ...) {
  stop("`as_gt()` supports bsvarPost tables and data frames only.", call. = FALSE)
}

#' @rdname reporting
#' @export
as_flextable <- function(x, ...) {
  UseMethod("as_flextable")
}

#' @rdname reporting
#' @export
as_flextable.bsvar_post_tbl <- function(x, caption = NULL, digits = NULL, ...) {
  ensure_namespace("flextable", "as_flextable()")
  report_table <- prepare_report_table(x, digits = digits)
  out <- flextable::flextable(report_table, ...)
  if (!is.null(caption)) {
    out <- flextable::set_caption(out, caption = caption)
  }
  out
}

#' @rdname reporting
#' @export
as_flextable.data.frame <- function(x, caption = NULL, digits = NULL, ...) {
  ensure_namespace("flextable", "as_flextable()")
  report_table <- prepare_report_table(x, digits = digits)
  out <- flextable::flextable(report_table, ...)
  if (!is.null(caption)) {
    out <- flextable::set_caption(out, caption = caption)
  }
  out
}

#' @rdname reporting
#' @export
as_flextable.default <- function(x, ...) {
  stop("`as_flextable()` supports bsvarPost tables and data frames only.", call. = FALSE)
}

#' @rdname reporting
#' @param file Output CSV path.
#' @param row.names Passed to [utils::write.csv()].
#' @export
write_bsvar_csv <- function(x, file, row.names = FALSE, ...) {
  report_table <- prepare_report_table(x)
  utils::write.csv(report_table, file = file, row.names = row.names, ...)
  invisible(normalizePath(file, winslash = "/", mustWork = FALSE))
}

prepare_report_table <- function(x, digits = NULL) {
  if (!inherits(x, "data.frame")) {
    stop("Reporting helpers require a bsvarPost table or data frame.", call. = FALSE)
  }
  out <- as.data.frame(x, stringsAsFactors = FALSE)
  if (!is.null(digits)) {
    numeric_cols <- vapply(out, is.numeric, logical(1))
    out[numeric_cols] <- lapply(out[numeric_cols], round, digits = digits)
  }
  out
}

ensure_namespace <- function(pkg, caller) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      sprintf("`%s` requires the optional package `%s`.", caller, pkg),
      call. = FALSE
    )
  }
}
