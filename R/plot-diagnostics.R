#' Plot acceptance diagnostics across metrics and models
#'
#' @param object A tidy acceptance-diagnostics table, or a `PosteriorBSVARSIGN`
#'   object that can be converted with `acceptance_diagnostics()`.
#' @param metrics Optional metric filter.
#' @param models Optional model filter.
#' @param show_flags If `TRUE`, highlight flagged diagnostics in a different
#'   colour.
#' @param ... Additional arguments passed to `acceptance_diagnostics()` when
#'   `object` is not already a diagnostics table.
#' @export
plot_acceptance_diagnostics <- function(object, metrics = NULL, models = NULL, show_flags = TRUE, ...) {
  if (inherits(object, "bsvar_post_tbl")) {
    diag_tbl <- object
  } else {
    diag_tbl <- acceptance_diagnostics(object, ...)
  }

  if (!identical(attr(diag_tbl, "object_type"), "acceptance_diagnostics")) {
    stop("`plot_acceptance_diagnostics()` requires an acceptance-diagnostics table or a 'PosteriorBSVARSIGN' object.", call. = FALSE)
  }

  df <- diag_tbl
  if (!is.null(metrics)) df <- df[df$metric %in% metrics, , drop = FALSE]
  if (!is.null(models)) df <- df[df$model %in% models, , drop = FALSE]
  if (!nrow(df)) {
    stop("No diagnostics remain after filtering.", call. = FALSE)
  }

  p <- ggplot2::ggplot(df, ggplot2::aes(x = stats::reorder(metric, value), y = value, fill = model))
  if (isTRUE(show_flags)) {
    p <- p + ggplot2::geom_col(ggplot2::aes(alpha = !flag), position = "dodge")
  } else {
    p <- p + ggplot2::geom_col(position = "dodge")
  }

  p +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "metric", y = "value", fill = if (length(unique(df$model)) > 1L) "model" else NULL)
}
