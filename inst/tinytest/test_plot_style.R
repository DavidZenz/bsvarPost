# Styling needs only a plot: no posterior estimation or HD conversion.
values <- data.frame(horizon = rep(0:2, 2), median = c(1:3, 2:4),
  model = rep(c("baseline", "alternative"), each = 3))
base_plot <- ggplot2::ggplot(values,
  ggplot2::aes(horizon, median, colour = model, fill = model)) +
  ggplot2::geom_ribbon(ggplot2::aes(ymin = median - 1, ymax = median + 1)) +
  ggplot2::geom_line()
palette <- c("#1b9e77", "#d95f02")
styled <- style_bsvar_plot(base_plot, preset = "paper", palette = palette,
  ribbon_alpha = 0.08, legend_position = "right")
built <- ggplot2::ggplot_build(styled)
expect_equal(sort(unique(built$data[[2]]$colour)), sort(palette))
expect_equal(sort(unique(built$data[[1]]$fill)), sort(palette))
expect_equal(unique(built$data[[1]]$alpha), 0.08)
expect_equal(styled$theme$legend.position, "right")

expect_true(inherits(theme_bsvarpost()$panel.grid.minor, "element_blank"))
expect_equal(theme_bsvarpost("paper")$legend.position, "bottom")
expect_true(theme_bsvarpost("slides", base_size = 12)$axis.text$size > 12)

# Family templates change labels and interval styling; they share one renderer.
labels <- c(irf = "impulse response", cdm = "cumulative dynamic multiplier",
  comparison = "comparison", shock_ranking = "median contribution")
for (family in names(labels)) {
  template <- template_bsvar_plot(base_plot, family = family)
  expect_equal(template$labels$y, unname(labels[family]), info = family)
}
expect_equal(template_bsvar_plot(base_plot, family = "irf")$layers[[1]]$aes_params$alpha, 0.14)

annotated <- annotate_bsvar_plot(base_plot, title = "IRFs", subtitle = "Demo",
  caption = "Posterior draws", yintercept = 0, xintercept = 2,
  xmin = 1, xmax = 2, window_alpha = 0.2)
expect_equal(c(annotated$labels$title, annotated$labels$subtitle, annotated$labels$caption),
  c("IRFs", "Demo", "Posterior draws"))
built <- ggplot2::ggplot_build(annotated)
expect_equal(unique(built$data[[3]]$yintercept), 0)
expect_equal(unique(built$data[[4]]$xintercept), 2)
expect_equal(built$data[[5]]$xmin, 1)
expect_equal(built$data[[5]]$xmax, 2)
expect_equal(built$data[[5]]$alpha, 0.2)

expect_error(style_bsvar_plot(values), "`plot` must be a ggplot object")
expect_error(template_bsvar_plot(values), "`plot` must be a ggplot object")
expect_error(annotate_bsvar_plot(values), "`plot` must be a ggplot object")
