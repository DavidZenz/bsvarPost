# Plot variants and event arithmetic use bounded draws, not repeated fits.
hd <- array(seq_len(60) / 100, c(1, 3, 4, 5),
  dimnames = list("gdp", c("ttr", "gs", "gdp"), as.character(1:4), as.character(1:5)))
class(hd) <- c("PosteriorHD", "array")
hd_tbl <- tidy_hd(hd)
event_start <- "1"
event_end <- "3"
p_lines <- plot_hd_lines(hd_tbl, variables = "gdp")
p_overlay <- plot_hd_overlay(hd, variables = "gdp", top_n = 2)
p_overlay_intervals <- plot_hd_overlay(hd, variables = "gdp", top_n = 2, intervals = TRUE)
p_share <- plot_hd_event_share(hd, start = event_start, end = event_end, top_n = 2)
p_cum <- plot_hd_event_cumulative(hd, start = event_start, end = event_end, top_n = 2)
p_dist <- plot_hd_event_distribution(hd, start = event_start, end = event_end, top_n = 2)

has_geom <- function(p, geom) any(vapply(p$layers,
  function(layer) inherits(layer$geom, geom), logical(1)))
expect_true(has_geom(p_lines, "GeomRibbon"))
expect_true(!has_geom(p_overlay, "GeomRibbon"))
expect_true(has_geom(p_overlay_intervals, "GeomRibbon"))
expect_true(has_geom(p_share, "GeomCol"))
expect_true(has_geom(p_cum, "GeomRibbon"))
expect_true(has_geom(p_dist, "GeomLinerange"))

prepared_groups <- bsvarPost:::prepare_hd_plot_data(hd, variables = "gdp",
  shock_groups = c(ttr = "Rates", gs = "Fiscal", gdp = "Real"), top_n = 2)
expect_true(all(prepared_groups$components$component %in% c("Rates", "Fiscal", "Real", "Other")))
expect_true("Other" %in% prepared_groups$components$component)
event_summary <- bsvarPost:::prepare_hd_event_plot_data(hd,
  start = event_start, end = event_end, top_n = 2)
event_abs <- bsvarPost:::compute_hd_event_shares(event_summary, share = "absolute")
expect_equal(sum(event_abs$share_value), 1, tolerance = 1e-8)
cumulative <- bsvarPost:::compute_hd_event_cumulative(hd,
  start = event_start, end = event_end, top_n = 2)$summary
cum_end <- subset(cumulative, time == event_end)
matched <- match(event_summary$component, cum_end$component)
expect_equal(cum_end$median[matched], event_summary$median)

# Stacked plots and observed/baseline reconstruction require a fitted model.
# Keep this integration boundary small; exact grouping has constructed fixtures
# in test_hardening_hd.R.
data(us_fiscal_lsuw, package = "bsvars")
set.seed(71)
post <- bsvars::estimate(bsvars::specify_bsvar$new(us_fiscal_lsuw[1:24, ], p = 1),
  S = 5, thin = 1, show_progress = FALSE)
p_stacked <- plot_hd_stacked(post, variables = "gdp", top_n = 2)
p_stacked_baseline <- plot_hd_stacked(post, variables = "gdp", top_n = 2, include_baseline = TRUE)
p_total <- plot_hd_total(post, variables = "gdp", shocks = "gs")
expect_true(has_geom(p_stacked, "GeomArea"))
expect_true(!has_geom(p_stacked, "GeomLine"))
expect_true(!"Baseline" %in% p_stacked$data$component)
expect_true("Baseline" %in% p_stacked_baseline$data$component)
expect_true("Displayed component total" %in% p_total$data$series)

# Reconciliation is an identity for each draw, not for marginal medians.
decomposition <- bsvarPost:::prepare_hd_decomposition_draws(post, variables = "gdp", top_n = 2)
reconstruction <- decomposition$components
reconstruction$component <- "Total"
reconstruction <- bsvarPost:::aggregate_hd_draw_rows(reconstruction)
observed <- decomposition$observed
key <- c("model", "variable", "time")
matched <- vctrs::vec_match(as.data.frame(reconstruction[key]), as.data.frame(observed[key]))
scale <- decomposition$components
scale$value <- abs(scale$value)
scale$component <- "Total"
scale <- bsvarPost:::aggregate_hd_draw_rows(scale)
expect_true(all(abs(reconstruction$value - observed$observed[matched]) <=
  pmax(1e-8, 64 * .Machine$double.eps * scale$value)))
filtered <- bsvarPost:::prepare_hd_decomposition_draws(post, variables = "gdp", shocks = "gs")
all_baseline <- subset(decomposition$components, component == "Baseline")
filtered_baseline <- subset(filtered$components, component == "Baseline")
key <- c("model", "variable", "time", "draw")
matched <- vctrs::vec_match(as.data.frame(all_baseline[key]), as.data.frame(filtered_baseline[key]))
expect_equal(all_baseline$value, filtered_baseline$value[matched], tolerance = 1e-8)
expect_true(!any(all_baseline$component == "Other"))
baseline_overlay <- plot_hd_overlay(post, variables = "gdp", top_n = 2, include_baseline = TRUE)
expect_true("Baseline" %in% baseline_overlay$data$series)

p_hd_pub <- publish_bsvar_plot(hd_tbl, preset = "paper")
expect_equal(p_hd_pub$labels$subtitle, "Full-sample contribution paths")
expect_true(!has_geom(p_hd_pub, "GeomRibbon"))
# One rendering smoke per distinct HD plotting implementation.
for (p in list(p_lines, p_overlay_intervals, p_stacked_baseline, p_total, p_share, p_cum, p_dist)) {
  expect_true(inherits(ggplot2::ggplot_build(p), "ggplot_built"))
}
expect_error(plot_hd_lines(tidy_hd_event(hd, start = event_start, end = event_end)),
  "object_type = 'hd'")
expect_error(plot_hd_event_cumulative(hd_tbl, start = event_start, end = event_end),
  "draw-level tidy table")
