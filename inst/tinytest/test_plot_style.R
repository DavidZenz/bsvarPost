data(us_fiscal_lsuw)
set.seed(13)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 5, thin = 1, show_progress = FALSE)

irf_tbl <- tidy_irf(post, horizon = 4)
base_plot <- ggplot2::autoplot(irf_tbl)

theme_obj <- theme_bsvarpost("paper")
styled_plot <- style_bsvar_plot(
  base_plot,
  preset = "paper",
  palette = c("#1b9e77", "#d95f02"),
  ribbon_alpha = 0.08,
  legend_position = "bottom"
)

expect_true(inherits(theme_obj, "theme"))
expect_true(inherits(styled_plot, "ggplot"))
expect_true(length(styled_plot$scales$scales) >= 2)

expect_error(
  style_bsvar_plot(irf_tbl),
  "`plot` must be a ggplot object",
  info = "style_bsvar_plot: fails clearly on non-ggplot input."
)
