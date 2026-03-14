data(us_fiscal_lsuw, package = "bsvars")
set.seed(71)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 5, thin = 1, show_progress = FALSE)

hd_tbl <- tidy_hd(post)
hd_draws <- tidy_hd(post, draws = TRUE)
hd_times <- unique(as.character(hd_draws$time))
event_start <- hd_times[1]
event_end <- hd_times[min(3, length(hd_times))]

p_lines <- plot_hd_lines(hd_tbl, variables = "gdp")
p_overlay <- plot_hd_overlay(post, variables = "gdp", top_n = 2)
p_overlay_intervals <- plot_hd_overlay(post, variables = "gdp", top_n = 2, intervals = TRUE)
p_stacked <- plot_hd_stacked(post, variables = "gdp", top_n = 2)
p_total <- plot_hd_total(post, variables = "gdp", shocks = "gs")
p_share <- plot_hd_event_share(post, start = event_start, end = event_end, top_n = 2)
p_cum <- plot_hd_event_cumulative(post, start = event_start, end = event_end, top_n = 2)
p_dist <- plot_hd_event_distribution(post, start = event_start, end = event_end, top_n = 2)

expect_true(inherits(p_lines, "ggplot"))
expect_true(inherits(p_overlay, "ggplot"))
expect_true(inherits(p_overlay_intervals, "ggplot"))
expect_true(inherits(p_stacked, "ggplot"))
expect_true(inherits(p_total, "ggplot"))
expect_true(inherits(p_share, "ggplot"))
expect_true(inherits(p_cum, "ggplot"))
expect_true(inherits(p_dist, "ggplot"))

expect_true(any(vapply(p_lines$layers, function(layer) inherits(layer$geom, "GeomRibbon"), logical(1))))
expect_true(any(vapply(p_overlay$layers, function(layer) inherits(layer$geom, "GeomLine"), logical(1))))
expect_true(!any(vapply(p_overlay$layers, function(layer) inherits(layer$geom, "GeomRibbon"), logical(1))))
expect_true(any(vapply(p_overlay_intervals$layers, function(layer) inherits(layer$geom, "GeomRibbon"), logical(1))))
expect_true(any(vapply(p_stacked$layers, function(layer) inherits(layer$geom, "GeomArea"), logical(1))))
expect_true(any(vapply(p_total$layers, function(layer) inherits(layer$geom, "GeomLine"), logical(1))))
expect_true(any(vapply(p_share$layers, function(layer) inherits(layer$geom, "GeomCol"), logical(1))))
expect_true(any(vapply(p_cum$layers, function(layer) inherits(layer$geom, "GeomRibbon"), logical(1))))
expect_true(any(vapply(p_dist$layers, function(layer) inherits(layer$geom, "GeomLinerange"), logical(1))))
expect_true(!any(vapply(p_stacked$layers, function(layer) inherits(layer$geom, "GeomLine"), logical(1))))

prepared_groups <- bsvarPost:::prepare_hd_plot_data(
  post,
  variables = "gdp",
  shock_groups = c(ttr = "Rates", gs = "Fiscal", gdp = "Real"),
  top_n = 2
)
expect_true(all(prepared_groups$components$component %in% c("Rates", "Fiscal", "Real", "Other")))

prepared_baseline <- bsvarPost:::prepare_hd_baseline_summary(post, variables = "gdp", top_n = 2)
baseline_rows <- prepared_baseline$components[prepared_baseline$components$component == "Baseline", , drop = FALSE]
expect_true(any(baseline_rows$component == "Baseline"))
expect_true(!any(baseline_rows$component == "Other"))

component_total <- do.call(
  rbind,
  lapply(
    split(prepared_baseline$components, interaction(prepared_baseline$components$model, prepared_baseline$components$variable, prepared_baseline$components$time, drop = TRUE)),
    function(part) {
      data.frame(
        model = part$model[1],
        variable = part$variable[1],
        time = part$time[1],
        total = sum(part$median, na.rm = TRUE)
      )
    }
  )
)
reconciled_summary <- merge(
  component_total,
  prepared_baseline$observed,
  by = c("model", "variable", "time"),
  all = TRUE,
  sort = FALSE
)
expect_true(isTRUE(all.equal(reconciled_summary$total, reconciled_summary$observed, tolerance = 1e-8)))

baseline_overlay <- plot_hd_overlay(post, variables = "gdp", top_n = 2, include_baseline = TRUE)
overlay_data <- ggplot2::ggplot_build(baseline_overlay)$plot$data
expect_true(any(overlay_data$series == "Baseline"))

event_summary <- bsvarPost:::prepare_hd_event_plot_data(post, start = event_start, end = event_end, top_n = 2)
event_abs <- bsvarPost:::compute_hd_event_shares(event_summary, share = "absolute")
share_totals <- split(event_abs$share_value, interaction(event_abs$model, event_abs$variable, drop = TRUE))
expect_true(all(vapply(share_totals, function(x) isTRUE(all.equal(sum(x), 1, tolerance = 1e-8)), logical(1))))

cumulative <- bsvarPost:::compute_hd_event_cumulative(post, start = event_start, end = event_end, top_n = 2)
cum_end <- cumulative$summary
cum_end <- cum_end[as.character(cum_end$time) == event_end, , drop = FALSE]
event_total_grouped <- bsvarPost:::prepare_hd_event_plot_data(post, start = event_start, end = event_end, top_n = 2)
cum_key <- paste(cum_end$model, cum_end$variable, cum_end$component, sep = "\r")
event_key <- paste(event_total_grouped$model, event_total_grouped$variable, event_total_grouped$component, sep = "\r")
cum_match <- cum_end[match(event_key, cum_key), , drop = FALSE]
expect_true(isTRUE(all.equal(cum_match$median, event_total_grouped$median, tolerance = 1e-8)))

p_hd_pub <- publish_bsvar_plot(hd_tbl, preset = "paper")
expect_true(inherits(p_hd_pub, "ggplot"))
expect_true(identical(p_hd_pub$labels$subtitle, "Full-sample contribution paths"))
expect_true(!any(vapply(p_hd_pub$layers, function(layer) inherits(layer$geom, "GeomRibbon"), logical(1))))

expect_error(
  plot_hd_lines(tidy_hd_event(post, start = event_start, end = event_end)),
  "object_type = 'hd'",
  info = "plot_hd_lines: rejects hd_event tables."
)

expect_error(
  plot_hd_event_cumulative(hd_tbl, start = event_start, end = event_end),
  "draw-level tidy table",
  info = "plot_hd_event_cumulative: requires draw-level HD input when supplied a tidy table."
)
