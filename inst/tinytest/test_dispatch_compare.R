Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec_sv <- bsvars::specify_bsvar_sv$new(us_fiscal_lsuw, p = 1)
post_sv1 <- bsvars::estimate(spec_sv, S = 5, thin = 1, show_progress = FALSE)
post_sv2 <- bsvars::estimate(spec_sv, S = 5, thin = 1, show_progress = FALSE)

# Helper: check bsvar_post_tbl with model column containing base + alt
check_compare_tbl <- function(result, name) {
  expect_true(inherits(result, "bsvar_post_tbl"),
    info = paste0(name, ": inherits bsvar_post_tbl"))
  expect_true(nrow(result) > 0,
    info = paste0(name, ": nrow > 0"))
  expect_true("model" %in% names(result),
    info = paste0(name, ": has model column"))
  expect_equal(sort(unique(result$model)), c("alt", "base"),
    info = paste0(name, ": model values are base and alt"))
  expect_true(isTRUE(attr(result, "compare")),
    info = paste0(name, ": compare attribute is TRUE"))
}

# 1. compare_irf
cmp_irf <- compare_irf(base = post_sv1, alt = post_sv2, horizon = 2)
check_compare_tbl(cmp_irf, "compare_irf")

# 2. compare_cdm
cmp_cdm <- compare_cdm(base = post_sv1, alt = post_sv2, horizon = 2)
check_compare_tbl(cmp_cdm, "compare_cdm")

# 3. compare_fevd
cmp_fevd <- compare_fevd(base = post_sv1, alt = post_sv2, horizon = 2)
check_compare_tbl(cmp_fevd, "compare_fevd")

# 4. compare_forecast (zero-reference function)
cmp_fc <- compare_forecast(base = post_sv1, alt = post_sv2, horizon = 2)
check_compare_tbl(cmp_fc, "compare_forecast")

# 5. compare_hd_event -- requires time labels from the posterior
times_sv1 <- unique(as.character(tidy_hd(post_sv1, draws = TRUE)$time))
times_sv2 <- unique(as.character(tidy_hd(post_sv2, draws = TRUE)$time))
time_window <- intersect(times_sv1, times_sv2)[1:2]
cmp_hd <- compare_hd_event(base = post_sv1, alt = post_sv2, start = time_window[1], end = time_window[2])
check_compare_tbl(cmp_hd, "compare_hd_event")
expect_true(all(c("event_start", "event_end", "median") %in% names(cmp_hd)),
  info = "compare_hd_event: has event columns")

# 6. compare_peak_response
cmp_peak <- compare_peak_response(base = post_sv1, alt = post_sv2, horizon = 2)
check_compare_tbl(cmp_peak, "compare_peak_response")
expect_true("median_value" %in% names(cmp_peak),
  info = "compare_peak_response: has median_value column")

# 7. compare_duration_response
cmp_dur <- compare_duration_response(base = post_sv1, alt = post_sv2, horizon = 2,
                                     relation = ">", value = 0)
check_compare_tbl(cmp_dur, "compare_duration_response")
expect_true("median_duration" %in% names(cmp_dur),
  info = "compare_duration_response: has median_duration column")

# 8. compare_half_life_response
cmp_hl <- compare_half_life_response(base = post_sv1, alt = post_sv2, horizon = 2)
check_compare_tbl(cmp_hl, "compare_half_life_response")
expect_true("median_half_life" %in% names(cmp_hl),
  info = "compare_half_life_response: has median_half_life column")

# 9. compare_time_to_threshold
cmp_ttt <- compare_time_to_threshold(base = post_sv1, alt = post_sv2, horizon = 2,
                                     relation = ">", value = 0)
check_compare_tbl(cmp_ttt, "compare_time_to_threshold")
expect_true("median_horizon" %in% names(cmp_ttt),
  info = "compare_time_to_threshold: has median_horizon column")

# 10. compare_restrictions -- uses restriction_audit with no restrictions (computes from sign matrix)
# This is only tested in test_dispatch_sign.R with PosteriorBSVARSIGN
