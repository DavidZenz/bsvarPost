#' Plot theme for bsvarPost outputs
#'
#' @param preset One of `"default"`, `"paper"`, or `"slides"`.
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @export
theme_bsvarpost <- function(preset = c("default", "paper", "slides"),
                            base_size = 11, base_family = "") {
  preset <- match.arg(preset)

  theme <- ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold"),
      plot.title = ggplot2::element_text(face = "bold"),
      legend.title = ggplot2::element_text(face = "bold")
    )

  if (identical(preset, "paper")) {
    theme <- theme + ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(colour = "grey85", linewidth = 0.25),
      axis.line = ggplot2::element_line(colour = "grey30"),
      axis.ticks = ggplot2::element_line(colour = "grey30"),
      legend.position = "bottom",
      strip.background = ggplot2::element_rect(fill = "grey95", colour = NA)
    )
  } else if (identical(preset, "slides")) {
    theme <- theme + ggplot2::theme(
      panel.grid.major = ggplot2::element_line(colour = "grey90", linewidth = 0.35),
      axis.text = ggplot2::element_text(size = base_size * 1.05),
      axis.title = ggplot2::element_text(size = base_size * 1.1),
      strip.text = ggplot2::element_text(size = base_size * 1.05),
      legend.position = "bottom"
    )
  }

  theme
}

#' Apply a publication-oriented style to a bsvarPost plot
#'
#' @param plot A `ggplot` object, typically returned by `ggplot2::autoplot()`,
#'   `plot_hd_event()`, or `plot_shock_ranking()`.
#' @param preset One of `"default"`, `"paper"`, or `"slides"`.
#' @param palette Optional vector of colours used for both line and fill scales.
#' @param ribbon_alpha Optional alpha override for ribbon layers.
#' @param base_size Base font size for the applied theme.
#' @param base_family Base font family for the applied theme.
#' @param legend_position Optional legend position override.
#' @export
style_bsvar_plot <- function(plot, preset = c("default", "paper", "slides"),
                             palette = NULL, ribbon_alpha = NULL,
                             base_size = 11, base_family = "",
                             legend_position = NULL) {
  if (!inherits(plot, "ggplot")) {
    stop("`plot` must be a ggplot object.", call. = FALSE)
  }

  preset <- match.arg(preset)
  plot <- plot + theme_bsvarpost(preset = preset, base_size = base_size, base_family = base_family)

  if (!is.null(palette)) {
    plot <- plot +
      ggplot2::scale_colour_manual(values = palette, aesthetics = c("colour")) +
      ggplot2::scale_fill_manual(values = palette, aesthetics = c("fill"))
  }

  if (!is.null(ribbon_alpha)) {
    for (i in seq_along(plot$layers)) {
      if (inherits(plot$layers[[i]]$geom, "GeomRibbon")) {
        plot$layers[[i]]$aes_params$alpha <- ribbon_alpha
      }
    }
  }

  if (!is.null(legend_position)) {
    plot <- plot + ggplot2::theme(legend.position = legend_position)
  }

  plot
}
