data(us_fiscal_lsuw)
set.seed(1)
spec_bsvar <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_bsvar <- estimate(spec_bsvar, S = 5, thin = 1, show_progress = FALSE)

hd_draws <- tidy_hd(post_bsvar, draws = TRUE)
time_window <- unique(as.character(hd_draws$time))[1:2]
event_draws <- tidy_hd_event(hd_draws, start = time_window[1], end = time_window[2], draws = TRUE)
expect_true(inherits(event_draws, "bsvar_post_tbl"))
expect_true(isTRUE(attr(event_draws, "draws")))

variable_1 <- unique(hd_draws$variable)[1]
shock_1 <- unique(hd_draws$shock)[1]
manual <- subset(hd_draws, variable == variable_1 & shock == shock_1 & time %in% time_window)
manual_sum <- tapply(manual$value, manual$draw, sum)
check_row <- subset(event_draws, variable == variable_1 & shock == shock_1)
expect_equal(unname(check_row$value), unname(as.numeric(manual_sum)))

event_summary <- tidy_hd_event(post_bsvar, start = time_window[1], end = time_window[2])
expect_true(inherits(event_summary, "bsvar_post_tbl"))
expect_true(all(c("event_start", "event_end", "median") %in% names(event_summary)))

ranked_abs <- shock_ranking(post_bsvar, start = time_window[1], end = time_window[2], ranking = "absolute")
expect_true(inherits(ranked_abs, "bsvar_post_tbl"))
expect_true(all(c("rank", "rank_score", "ranking") %in% names(ranked_abs)))

var_block <- subset(ranked_abs, model == ranked_abs$model[1] & variable == ranked_abs$variable[1])
expect_equal(var_block$rank, seq_len(nrow(var_block)))
expect_true(all(diff(var_block$rank_score) <= 0))

ranked_signed <- shock_ranking(post_bsvar, start = time_window[1], end = time_window[2], ranking = "signed")
expect_true(all(ranked_signed$ranking == "signed"))

expect_error(
  tidy_hd_event(tidy_hd(post_bsvar, draws = FALSE), start = time_window[1], end = time_window[2]),
  pattern = "draw-level tidy HD table",
  info = "tidy_hd_event: summary-level tidy HD input fails clearly."
)
