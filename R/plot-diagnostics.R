#' Plot acceptance diagnostics across metrics and models
#'
#' @param object A tidy acceptance-diagnostics table, or a `PosteriorBSVARSIGN`
#'   object that can be converted with `acceptance_diagnostics()`.
#' @param metrics Optional metric filter.
#' @param models Optional model filter.
#' @param show_flags If `TRUE`, highlight flagged diagnostics in a different
#'   marker.
#' @param preset One of `"default"`, `"paper"`, or `"slides"`.
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @param title Optional plot title.
#' @param subtitle Optional plot subtitle.
#' @param caption Optional plot caption.
#' @param ... Additional arguments passed to `acceptance_diagnostics()` when
#'   `object` is not already a diagnostics table.
#' @return A grid plot object.
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
plot_acceptance_diagnostics <- function(object, metrics = NULL, models = NULL, show_flags = TRUE,
                                        preset = c("default", "paper", "slides"),
                                        base_size = 11, base_family = "",
                                        title = NULL, subtitle = NULL, caption = NULL,
                                        ...) {
  preset <- match.arg(preset)

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
  family_levels <- unique(df[order(df$family_order), "family"])
  legend_plot <- build_acceptance_diagnostics_panel(
    df,
    preset = preset,
    base_size = base_size,
    base_family = base_family,
    show_flags = show_flags,
    show_legend = TRUE
  )
  legend_grob <- extract_acceptance_diagnostics_legend(legend_plot)

  panel_plots <- lapply(family_levels, function(family_name) {
    build_acceptance_diagnostics_panel(
      df[df$family == family_name, , drop = FALSE],
      preset = preset,
      base_size = base_size,
      base_family = base_family,
      show_flags = show_flags,
      show_legend = FALSE
    )
  })
  panel_grobs <- lapply(panel_plots, ggplot2::ggplotGrob)
  panel_grobs <- align_acceptance_diagnostics_widths(panel_grobs)
  panel_weights <- vapply(split(df, df$family), function(part) nrow(part) + 1, numeric(1))
  panel_weights <- panel_weights[family_levels]

  build_acceptance_diagnostics_composite(
    panel_grobs = panel_grobs,
    panel_weights = panel_weights,
    legend_grob = legend_grob,
    title = title,
    subtitle = subtitle,
    caption = caption,
    base_size = base_size
  )
}

build_acceptance_diagnostics_panel <- function(df, preset, base_size, base_family,
                                               show_flags, show_legend) {
  label_levels <- unique(df[order(df$metric_order), "label"])
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
    theme_bsvarpost(
      preset = preset,
      base_size = base_size,
      base_family = base_family
    ) +
    ggplot2::scale_colour_manual(values = c("#4c78a8", "#e45756", "#72b7b2", "#f58518")) +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold"),
      panel.spacing.y = ggplot2::unit(0.1, "lines")
    ) +
    ggplot2::labs(
      x = "value",
      y = NULL,
      colour = if (length(unique(df$model)) > 1L) "model" else NULL
    )

  if (isTRUE(show_flags) && any(df$flag)) {
    p <- p + ggplot2::scale_shape_manual(
      values = c("Warning flag" = 21),
      name = NULL,
      labels = c("Warning flag" = "Warning threshold exceeded")
    )
  }

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
    )
  }

  if (!show_legend) {
    p <- p + ggplot2::theme(legend.position = "none")
  } else if (isTRUE(show_flags) && any(df$flag)) {
    p <- p + ggplot2::theme(legend.position = "bottom")
  } else if (length(unique(df$model)) <= 1L) {
    p <- p + ggplot2::theme(legend.position = "none")
  }

  p
}

extract_acceptance_diagnostics_legend <- function(plot) {
  grob <- ggplot2::ggplotGrob(plot)
  idx <- which(grob$layout$name == "guide-box")
  if (!length(idx)) return(NULL)
  grob$grobs[[idx[1]]]
}

align_acceptance_diagnostics_widths <- function(grobs) {
  max_widths <- grobs[[1]]$widths
  if (length(grobs) > 1L) {
    for (i in 2:length(grobs)) {
      max_widths <- grid::unit.pmax(max_widths, grobs[[i]]$widths)
    }
  }
  lapply(grobs, function(grob) {
    grob$widths <- max_widths
    grob
  })
}

build_acceptance_diagnostics_composite <- function(panel_grobs, panel_weights, legend_grob = NULL,
                                                   title = NULL, subtitle = NULL, caption = NULL,
                                                   base_size = 11) {
  grobs <- list()
  heights <- list()

  if (!is.null(title)) {
    grobs[[length(grobs) + 1L]] <- grid::textGrob(
      title, x = 0, hjust = 0,
      gp = grid::gpar(fontface = "bold", fontsize = base_size * 1.15)
    )
    heights[[length(heights) + 1L]] <- grid::unit(1.4, "lines")
  }

  if (!is.null(subtitle)) {
    grobs[[length(grobs) + 1L]] <- grid::textGrob(
      subtitle, x = 0, hjust = 0,
      gp = grid::gpar(fontsize = base_size * 0.95, col = "grey30")
    )
    heights[[length(heights) + 1L]] <- grid::unit(1.1, "lines")
  }

  for (i in seq_along(panel_grobs)) {
    grobs[[length(grobs) + 1L]] <- panel_grobs[[i]]
    heights[[length(heights) + 1L]] <- grid::unit(panel_weights[[i]], "null")
  }

  if (!is.null(legend_grob)) {
    grobs[[length(grobs) + 1L]] <- legend_grob
    heights[[length(heights) + 1L]] <- grid::grobHeight(legend_grob) + grid::unit(0.4, "lines")
  }

  if (!is.null(caption)) {
    grobs[[length(grobs) + 1L]] <- grid::textGrob(
      caption, x = 0, hjust = 0,
      gp = grid::gpar(fontsize = base_size * 0.85, col = "grey35")
    )
    heights[[length(heights) + 1L]] <- grid::unit(1, "lines")
  }

  layout <- grid::grid.layout(
    nrow = length(grobs),
    ncol = 1,
    heights = do.call(grid::unit.c, heights)
  )
  children <- mapply(function(grob, row) {
    grid::grobTree(
      grob,
      vp = grid::viewport(layout.pos.row = row, layout.pos.col = 1)
    )
  }, grobs, seq_along(grobs), SIMPLIFY = FALSE)

  structure(
    grid::gTree(
      children = do.call(grid::gList, children),
      vp = grid::viewport(layout = layout)
    ),
    class = c("bsvar_diagnostics_plot", "gTree", "grob", "gDesc"),
    plot_meta = list(title = title, subtitle = subtitle, caption = caption)
  )
}

#' @export
print.bsvar_diagnostics_plot <- function(x, ...) {
  grid::grid.newpage()
  grid::grid.draw(x)
  invisible(x)
}
