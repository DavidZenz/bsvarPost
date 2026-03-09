data(us_fiscal_lsuw)
set.seed(11)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 5, thin = 1, show_progress = FALSE)

hd_draws <- tidy_hd(post, draws = TRUE)
time_window <- unique(as.character(hd_draws$time))[1:2]
hd_tbl <- tidy_hd_event(post, start = time_window[1], end = time_window[2])
rank_tbl <- shock_ranking(post, start = time_window[1], end = time_window[2], ranking = "absolute")

p_hd1 <- plot_hd_event(post, start = time_window[1], end = time_window[2])
p_hd2 <- plot_hd_event(hd_tbl)
p_rank1 <- plot_shock_ranking(post, start = time_window[1], end = time_window[2], ranking = "absolute", top_n = 3)
p_rank2 <- plot_shock_ranking(rank_tbl, top_n = 2)

expect_true(inherits(p_hd1, "ggplot"))
expect_true(inherits(p_hd2, "ggplot"))
expect_true(inherits(p_rank1, "ggplot"))
expect_true(inherits(p_rank2, "ggplot"))
expect_true(any(vapply(p_hd1$layers, function(layer) inherits(layer$geom, "GeomPoint"), logical(1))))
expect_true(any(vapply(p_hd1$layers, function(layer) inherits(layer$geom, "GeomLinerange"), logical(1))))

expect_error(
  plot_hd_event(post),
  "`start` must be supplied",
  info = "plot_hd_event: requires explicit event window for non-HD-event inputs."
)

expect_error(
  plot_shock_ranking(post),
  "`start` must be supplied",
  info = "plot_shock_ranking: requires explicit event window for non-ranking inputs."
)
