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
#' @param object A `bsvar_post_tbl`, data frame, or `bsvar_report_bundle`.
#' @param plot Optional `ggplot` object. If omitted, `bsvarPost` will try to
#'   choose a sensible default plot for the supplied table.
#' @param caption Optional table caption.
#' @param digits Optional number of digits used to round numeric columns before
#'   rendering.
#' @param preset Reporting preset. Use `"compact"` for a narrower,
#'   publication-oriented column selection.
#' @export
report_bundle <- function(object, plot = NULL, caption = NULL, digits = NULL,
                          preset = c("default", "compact"), ...) {
  table_data <- prepare_report_table(object, digits = digits, preset = preset)
  bundle_plot <- if (!is.null(plot)) plot else infer_report_plot(object, ...)
  structure(
    list(
      table = table_data,
      plot = bundle_plot,
      caption = caption,
      object_type = attr(object, "object_type") %||% NULL
    ),
    class = "bsvar_report_bundle"
  )
}

#' @rdname reporting
#' @export
report_table <- function(x, ...) {
  UseMethod("report_table")
}

#' @rdname reporting
#' @export
report_table.bsvar_post_tbl <- function(x, digits = NULL, preset = c("default", "compact"), ...) {
  prepare_report_table(x, digits = digits, preset = preset)
}

#' @rdname reporting
#' @export
report_table.data.frame <- function(x, digits = NULL, preset = c("default", "compact"), ...) {
  prepare_report_table(x, digits = digits, preset = preset)
}

#' @rdname reporting
#' @export
report_table.bsvar_report_bundle <- function(x, digits = NULL, preset = c("default", "compact"), ...) {
  prepare_report_table(x, digits = digits, preset = preset)
}

#' @rdname reporting
#' @export
report_table.default <- function(x, ...) {
  stop("`report_table()` supports bsvarPost tables and data frames only.", call. = FALSE)
}

#' @rdname reporting
#' @export
as_kable <- function(x, ...) {
  UseMethod("as_kable")
}

#' @rdname reporting
#' @export
as_kable.bsvar_post_tbl <- function(x, caption = NULL, digits = NULL,
                                    preset = c("default", "compact"), ...) {
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  knitr::kable(report_table, caption = caption, ...)
}

#' @rdname reporting
#' @export
as_kable.data.frame <- function(x, caption = NULL, digits = NULL,
                                preset = c("default", "compact"), ...) {
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  knitr::kable(report_table, caption = caption, ...)
}

#' @rdname reporting
#' @export
as_kable.bsvar_report_bundle <- function(x, caption = NULL, digits = NULL,
                                         preset = c("default", "compact"), ...) {
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  knitr::kable(report_table, caption = caption %||% x$caption, ...)
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
as_gt.bsvar_post_tbl <- function(x, caption = NULL, digits = NULL,
                                 preset = c("default", "compact"), ...) {
  ensure_namespace("gt", "as_gt()")
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  out <- gt::gt(report_table, ...)
  if (!is.null(caption)) {
    out <- gt::tab_header(out, title = caption)
  }
  out
}

#' @rdname reporting
#' @export
as_gt.data.frame <- function(x, caption = NULL, digits = NULL,
                             preset = c("default", "compact"), ...) {
  ensure_namespace("gt", "as_gt()")
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  out <- gt::gt(report_table, ...)
  if (!is.null(caption)) {
    out <- gt::tab_header(out, title = caption)
  }
  out
}

#' @rdname reporting
#' @export
as_gt.bsvar_report_bundle <- function(x, caption = NULL, digits = NULL,
                                      preset = c("default", "compact"), ...) {
  ensure_namespace("gt", "as_gt()")
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  out <- gt::gt(report_table, ...)
  final_caption <- caption %||% x$caption
  if (!is.null(final_caption)) {
    out <- gt::tab_header(out, title = final_caption)
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
as_flextable.bsvar_post_tbl <- function(x, caption = NULL, digits = NULL,
                                        preset = c("default", "compact"), ...) {
  ensure_namespace("flextable", "as_flextable()")
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  out <- flextable::flextable(report_table, ...)
  if (!is.null(caption)) {
    out <- flextable::set_caption(out, caption = caption)
  }
  out
}

#' @rdname reporting
#' @export
as_flextable.data.frame <- function(x, caption = NULL, digits = NULL,
                                    preset = c("default", "compact"), ...) {
  ensure_namespace("flextable", "as_flextable()")
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  out <- flextable::flextable(report_table, ...)
  if (!is.null(caption)) {
    out <- flextable::set_caption(out, caption = caption)
  }
  out
}

#' @rdname reporting
#' @export
as_flextable.bsvar_report_bundle <- function(x, caption = NULL, digits = NULL,
                                             preset = c("default", "compact"), ...) {
  ensure_namespace("flextable", "as_flextable()")
  report_table <- prepare_report_table(x, digits = digits, preset = preset)
  out <- flextable::flextable(report_table, ...)
  final_caption <- caption %||% x$caption
  if (!is.null(final_caption)) {
    out <- flextable::set_caption(out, caption = final_caption)
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
write_bsvar_csv <- function(x, file, row.names = FALSE,
                            preset = c("default", "compact"), ...) {
  report_table <- prepare_report_table(x, preset = preset)
  utils::write.csv(report_table, file = file, row.names = row.names, ...)
  invisible(normalizePath(file, winslash = "/", mustWork = FALSE))
}

#' @rdname reporting
#' @export
print.bsvar_report_bundle <- function(x, ...) {
  cat("<bsvar_report_bundle>\n", sep = "")
  cat("rows:", nrow(x$table), "cols:", ncol(x$table), "\n")
  if (!is.null(x$object_type)) {
    cat("object_type:", x$object_type, "\n")
  }
  if (!is.null(x$caption)) {
    cat("caption:", x$caption, "\n")
  }
  if (!is.null(x$plot)) {
    cat("plot: available\n")
  } else {
    cat("plot: not available\n")
  }
  invisible(x)
}

prepare_report_table <- function(x, digits = NULL, preset = c("default", "compact")) {
  preset <- match.arg(preset)
  if (inherits(x, "bsvar_report_bundle")) {
    out <- x$table
  } else if (inherits(x, "RepresentativeResponse")) {
    out <- summary(x)
  } else {
    if (!inherits(x, "data.frame")) {
      stop("Reporting helpers require a bsvarPost table or data frame.", call. = FALSE)
    }
    out <- as.data.frame(x, stringsAsFactors = FALSE)
  }
  if (!is.null(digits)) {
    numeric_cols <- vapply(out, is.numeric, logical(1))
    out[numeric_cols] <- lapply(out[numeric_cols], round, digits = digits)
  }
  format_report_columns(out, preset = preset)
}

ensure_namespace <- function(pkg, caller) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      sprintf("`%s` requires the optional package `%s`.", caller, pkg),
      call. = FALSE
    )
  }
}

infer_report_plot <- function(object, ...) {
  if (inherits(object, "bsvar_report_bundle")) {
    return(object$plot %||% NULL)
  }
  if (inherits(object, "RepresentativeResponse")) {
    return(build_representative_plot(object))
  }
  if (!inherits(object, "bsvar_post_tbl")) {
    return(NULL)
  }

  object_type <- attr(object, "object_type") %||% ""
  if (identical(object_type, "acceptance_diagnostics")) {
    return(plot_acceptance_diagnostics(object, ...))
  }
  if (grepl("^simultaneous_", object_type)) {
    return(plot_simultaneous(object, ...))
  }
  if (grepl("^joint_", object_type)) {
    return(plot_joint_hypothesis(object, ...))
  }
  if (isTRUE(attr(object, "compare"))) {
    if (identical(object_type, "restriction_audit")) {
      return(plot_compare_restrictions(object, ...))
    }
    if (object_type %in% c(
      "peak_irf", "peak_cdm",
      "duration_irf", "duration_cdm",
      "half_life_irf", "half_life_cdm",
      "time_to_threshold_irf", "time_to_threshold_cdm"
    )) {
      return(plot_compare_response(object, ...))
    }
  }

  ggplot2::autoplot(object, ...)
}

format_report_columns <- function(x, preset = c("default", "compact")) {
  preset <- match.arg(preset)

  preferred <- c(
    "model", "variable", "shock", "horizon", "time", "event_start", "event_end",
    "restriction_type", "restriction", "relation", "value", "threshold", "mode", "baseline",
    "posterior_prob", "reached_prob", "n_constraints", "critical_value",
    "mean", "median", "lower", "upper",
    "mean_gap", "median_gap", "lower_gap", "upper_gap",
    "mean_value", "median_value", "lower_value", "upper_value",
    "mean_duration", "median_duration", "lower_duration", "upper_duration",
    "mean_half_life", "median_half_life", "lower_half_life", "upper_half_life",
    "mean_horizon", "median_horizon", "lower_horizon", "upper_horizon"
  )

  if (identical(preset, "compact")) {
    keep <- intersect(preferred, names(x))
    if (length(keep)) {
      x <- x[, keep, drop = FALSE]
    }
  } else {
    lead <- intersect(preferred, names(x))
    tail <- setdiff(names(x), lead)
    x <- x[, c(lead, tail), drop = FALSE]
  }

  x
}
