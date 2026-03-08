data(us_fiscal_lsuw)
set.seed(17)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 5, thin = 1, show_progress = FALSE)

irf_tbl <- tidy_irf(post, horizon = 4)
cmp_tbl <- compare_irf(base = post, alt = post, horizon = 4)
rank_plot <- plot_shock_ranking(post, start = unique(as.character(tidy_hd(post, draws = TRUE)$time))[1], end = unique(as.character(tidy_hd(post, draws = TRUE)$time))[2])

p_irf <- template_bsvar_plot(ggplot2::autoplot(irf_tbl), family = "irf", preset = "paper")
p_cmp <- template_bsvar_plot(ggplot2::autoplot(cmp_tbl), family = "comparison")
p_rank <- template_bsvar_plot(rank_plot, family = "shock_ranking", preset = "slides")

annotated <- annotate_bsvar_plot(
  p_irf,
  title = "IRF overview",
  subtitle = "Template test",
  caption = "bsvarPost",
  yintercept = 0,
  xintercept = 2,
  xmin = 1,
  xmax = 2
)

expect_true(inherits(p_irf, "ggplot"))
expect_true(inherits(p_cmp, "ggplot"))
expect_true(inherits(p_rank, "ggplot"))
expect_true(inherits(annotated, "ggplot"))

expect_error(
  template_bsvar_plot(irf_tbl, family = "irf"),
  "`plot` must be a ggplot object",
  info = "template_bsvar_plot: fails clearly on non-ggplot input."
)

expect_error(
  annotate_bsvar_plot(irf_tbl, title = "bad"),
  "`plot` must be a ggplot object",
  info = "annotate_bsvar_plot: fails clearly on non-ggplot input."
)
