#' Plot theme for bsvarPost outputs
#'
#' @param preset One of `"default"`, `"paper"`, or `"slides"`.
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @return A \code{ggplot2} theme object.
#' @examples
#' th <- theme_bsvarpost(preset = "paper")
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
#' @return A \code{ggplot} object with the applied style.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' irf_tbl <- tidy_irf(post, horizon = 3)
#' p <- style_bsvar_plot(ggplot2::autoplot(irf_tbl), preset = "paper")
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
    if (!plot$scales$has_scale("colour")) {
      plot <- plot + ggplot2::scale_colour_manual(values = palette, aesthetics = c("colour"))
    }
    if (!plot$scales$has_scale("fill")) {
      plot <- plot + ggplot2::scale_fill_manual(values = palette, aesthetics = c("fill"))
    }
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

#' Apply an output-family template to a bsvarPost plot
#'
#' @param plot A `ggplot` object.
#' @param family One of `"irf"`, `"cdm"`, `"forecast"`, `"hd_event"`,
#'   `"shock_ranking"`, `"hypothesis"`, `"restriction_audit"`,
#'   `"simultaneous"`, `"joint_hypothesis"`, `"acceptance_diagnostics"`,
#'   `"representative"`, or `"comparison"`.
#' @param preset One of `"default"`, `"paper"`, or `"slides"`.
#' @param base_size Base font size for the applied theme.
#' @param base_family Base font family for the applied theme.
#' @return A \code{ggplot} object with template styling applied.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' irf_tbl <- tidy_irf(post, horizon = 3)
#' p <- template_bsvar_plot(ggplot2::autoplot(irf_tbl), family = "irf")
#' @export
template_bsvar_plot <- function(plot, family = c("irf", "cdm", "forecast", "hd_event", "shock_ranking",
                                                 "hypothesis", "restriction_audit", "simultaneous",
                                                 "joint_hypothesis", "acceptance_diagnostics",
                                                 "representative", "comparison"),
                                preset = c("default", "paper", "slides"),
                                base_size = 11, base_family = "") {
  if (!inherits(plot, "ggplot")) {
    stop("`plot` must be a ggplot object.", call. = FALSE)
  }

  family <- match.arg(family)
  preset <- match.arg(preset)

  defaults <- switch(
    family,
    irf = list(palette = c("#1f78b4", "#a6cee3"), ribbon_alpha = 0.14, legend_position = "bottom"),
    cdm = list(palette = c("#0b6e4f", "#88c9a1"), ribbon_alpha = 0.14, legend_position = "bottom"),
    forecast = list(palette = c("#6a3d9a", "#cab2d6"), ribbon_alpha = 0.14, legend_position = "bottom"),
    hd_event = list(palette = c("#8c510a", "#d8b365"), ribbon_alpha = 0.10, legend_position = "bottom"),
    shock_ranking = list(palette = c("#b2182b", "#2166ac"), ribbon_alpha = NULL, legend_position = "bottom"),
    hypothesis = list(palette = c("#1b9e77", "#66a61e", "#d95f02"), ribbon_alpha = NULL, legend_position = "bottom"),
    restriction_audit = list(palette = c("#4c78a8", "#f58518", "#54a24b"), ribbon_alpha = NULL, legend_position = "bottom"),
    simultaneous = list(palette = c("#1f78b4", "#a6cee3"), ribbon_alpha = 0.14, legend_position = "bottom"),
    joint_hypothesis = list(palette = c("#1b9e77", "#66a61e"), ribbon_alpha = NULL, legend_position = "bottom"),
    acceptance_diagnostics = list(palette = c("#4c78a8", "#e45756"), ribbon_alpha = NULL, legend_position = "bottom"),
    representative = list(palette = c("#2171b5", "#cb181d"), ribbon_alpha = 0.18, legend_position = "bottom"),
    comparison = list(palette = c("#1b9e77", "#d95f02", "#7570b3"), ribbon_alpha = 0.10, legend_position = "bottom")
  )

  styled <- style_bsvar_plot(
    plot,
    preset = preset,
    palette = defaults$palette,
    ribbon_alpha = defaults$ribbon_alpha,
    base_size = base_size,
    base_family = base_family,
    legend_position = defaults$legend_position
  )

  ylabel <- switch(
    family,
    irf = "impulse response",
    cdm = "cumulative dynamic multiplier",
    forecast = "forecast",
    hd_event = "event contribution",
    shock_ranking = "median contribution",
    hypothesis = "posterior probability",
    restriction_audit = "posterior satisfaction probability",
    simultaneous = "response",
    joint_hypothesis = "joint posterior probability",
    acceptance_diagnostics = "diagnostic value",
    representative = "response",
    comparison = "comparison"
  )

  styled + ggplot2::labs(y = ylabel)
}

#' Add publication-oriented annotations to a bsvarPost plot
#'
#' @param plot A `ggplot` object.
#' @param title Optional plot title.
#' @param subtitle Optional plot subtitle.
#' @param caption Optional plot caption.
#' @param yintercept Optional numeric vector of horizontal reference lines.
#' @param xintercept Optional numeric vector of vertical reference lines.
#' @param xmin Optional start of a highlighted x-window.
#' @param xmax Optional end of a highlighted x-window.
#' @param window_fill Fill colour for the highlighted window.
#' @param window_alpha Alpha for the highlighted window.
#' @return A \code{ggplot} object with annotations added.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' irf_tbl <- tidy_irf(post, horizon = 3)
#' p <- annotate_bsvar_plot(ggplot2::autoplot(irf_tbl), title = "IRFs")
#' @export
annotate_bsvar_plot <- function(plot, title = NULL, subtitle = NULL, caption = NULL,
                                yintercept = NULL, xintercept = NULL,
                                xmin = NULL, xmax = NULL,
                                window_fill = "grey70", window_alpha = 0.12) {
  if (!inherits(plot, "ggplot")) {
    stop("`plot` must be a ggplot object.", call. = FALSE)
  }

  if (!is.null(title) || !is.null(subtitle) || !is.null(caption)) {
    plot <- plot + ggplot2::labs(title = title, subtitle = subtitle, caption = caption)
  }

  if (!is.null(yintercept)) {
    plot <- plot + ggplot2::geom_hline(yintercept = yintercept, linetype = 3, colour = "grey40")
  }

  if (!is.null(xintercept)) {
    plot <- plot + ggplot2::geom_vline(xintercept = xintercept, linetype = 3, colour = "grey40")
  }

  if (!is.null(xmin) && !is.null(xmax)) {
    plot <- plot + ggplot2::annotate(
      "rect",
      xmin = xmin,
      xmax = xmax,
      ymin = -Inf,
      ymax = Inf,
      fill = window_fill,
      alpha = window_alpha
    )
  }

  plot
}
