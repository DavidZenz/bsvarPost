#' Plot acceptance diagnostics across metrics and models
#'
#' @param object A tidy acceptance-diagnostics table, or a `PosteriorBSVARSIGN`
#'   object that can be converted with `acceptance_diagnostics()`.
#' @param metrics Optional metric filter.
#' @param models Optional model filter.
#' @param show_flags If `TRUE`, highlight flagged diagnostics in a different
#'   marker.
#' @param ... Additional arguments passed to `acceptance_diagnostics()` when
#'   `object` is not already a diagnostics table.
#' @return A \code{ggplot} object.
#' @examples
#' \donttest{
#' data(optimism, package = "bsvarSIGNs")
#' sign_irf <- matrix(c(1, rep(NA, 3)), 2, 2)
#' spec_s <- suppressMessages(
#'   bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1,
#'                                      sign_irf = sign_irf)
#' )
#' post_s <- bsvars::estimate(spec_s, S = 5, show_progress = FALSE)
#'
#' p <- plot_acceptance_diagnostics(post_s)
#' }
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

  df <- attach_acceptance_diagnostic_metadata(df)
  label_levels <- unique(df[order(df$family_order, df$metric_order), "label"])
  df$label <- factor(df$label, levels = rev(label_levels))

  dodge <- ggplot2::position_dodge(width = 0.6)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = value, y = label, colour = model))
  p <- p +
    ggplot2::geom_segment(
      ggplot2::aes(x = 0, xend = value, yend = label),
      linewidth = 0.6,
      position = dodge,
      alpha = 0.8
    ) +
    ggplot2::geom_point(
      size = 2.4,
      position = dodge
    )

  if (isTRUE(show_flags) && any(df$flag)) {
    p <- p + ggplot2::geom_point(
      data = df[df$flag, , drop = FALSE],
      ggplot2::aes(x = value, y = label, shape = "Warning flag"),
      inherit.aes = FALSE,
      size = 3.2,
      stroke = 0.7,
      fill = "#e45756",
      colour = "#7f1d1d",
      position = dodge
    )
  }

  p <- p +
    ggplot2::facet_wrap(~ family, ncol = 1, scales = "free") +
    ggplot2::scale_x_continuous(
      breaks = function(x) pretty(x, n = 5),
      expand = ggplot2::expansion(mult = c(0.02, 0.16))
    ) +
    ggplot2::scale_shape_manual(
      values = c("Warning flag" = 21),
      name = NULL,
      labels = c("Warning flag" = "Warning threshold exceeded")
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold")
    ) +
    ggplot2::labs(
      x = "value",
      y = NULL,
      colour = if (length(unique(df$model)) > 1L) "model" else NULL
    )

  if (length(unique(df$model)) <= 1L) {
    p <- p + ggplot2::guides(colour = "none")
  }

  if (isTRUE(show_flags) && any(df$flag)) {
    p <- p + ggplot2::guides(
      shape = ggplot2::guide_legend(
        override.aes = list(
          fill = "#e45756",
          colour = "#7f1d1d",
          size = 3.2,
          stroke = 0.7
        ),
        order = 2
      )
    ) + ggplot2::theme(legend.position = "bottom")
  } else if (length(unique(df$model)) <= 1L) {
    p <- p + ggplot2::theme(legend.position = "none")
  }

  p
}
