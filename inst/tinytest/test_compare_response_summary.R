data(us_fiscal_lsuw)
set.seed(1)
spec_a <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
spec_b <- specify_bsvar$new(us_fiscal_lsuw, p = 2)
post_a <- estimate(spec_a, S = 5, thin = 1, show_progress = FALSE)
post_b <- estimate(spec_b, S = 5, thin = 1, show_progress = FALSE)

cmp_peak <- compare_peak_response(base = post_a, alt = post_b, type = "irf", horizon = 4, variable = 1, shock = 1)
expect_true(inherits(cmp_peak, "bsvar_post_tbl"))
expect_true(isTRUE(attr(cmp_peak, "compare")))
expect_equal(sort(unique(cmp_peak$model)), c("alt", "base"))
expect_true(all(c("median_value", "median_horizon") %in% names(cmp_peak)))

cmp_duration <- compare_duration_response(base = post_a, alt = post_b, type = "cdm", horizon = 4,
                                          variable = 1, shock = 1, relation = ">", value = 0, mode = "total")
expect_true(inherits(cmp_duration, "bsvar_post_tbl"))
expect_true(isTRUE(attr(cmp_duration, "compare")))
expect_true(all(c("median_duration", "mode", "threshold") %in% names(cmp_duration)))

p1 <- ggplot2::autoplot(cmp_peak)
p2 <- ggplot2::autoplot(cmp_duration)
expect_true(inherits(p1, "ggplot"))
expect_true(inherits(p2, "ggplot"))
