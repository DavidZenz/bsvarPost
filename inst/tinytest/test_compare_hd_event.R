data(us_fiscal_lsuw)
set.seed(1)
spec_a <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
spec_b <- specify_bsvar$new(us_fiscal_lsuw, p = 2)
post_a <- estimate(spec_a, S = 5, thin = 1, show_progress = FALSE)
post_b <- estimate(spec_b, S = 5, thin = 1, show_progress = FALSE)

times_a <- unique(as.character(tidy_hd(post_a, draws = TRUE)$time))
times_b <- unique(as.character(tidy_hd(post_b, draws = TRUE)$time))
time_window <- intersect(times_a, times_b)[1:2]
cmp_hd <- compare_hd_event(base = post_a, alt = post_b, start = time_window[1], end = time_window[2])
expect_true(inherits(cmp_hd, "bsvar_post_tbl"))
expect_true(isTRUE(attr(cmp_hd, "compare")))
expect_equal(sort(unique(cmp_hd$model)), c("alt", "base"))
expect_true(all(c("event_start", "event_end", "median") %in% names(cmp_hd)))

p <- ggplot2::autoplot(cmp_hd)
expect_true(inherits(p, "ggplot"))
