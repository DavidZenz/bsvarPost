Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# ---- PosteriorBSVAR fixture (S=30) ----
data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b  <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b  <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)
irf_raw <- bsvars::compute_impulse_responses(post_b, horizon = 8)

# ---- Test 1: peak_response values and horizons (variable=1, shock=1) ----
manual_peak_values <- vapply(seq_len(30), function(s) {
  path <- irf_raw[1, 1, , s]
  path[which.max(path)]
}, numeric(1))

manual_peak_horizons <- vapply(seq_len(30), function(s) {
  path <- irf_raw[1, 1, , s]
  horizons <- 0:8
  horizons[which.max(path)]
}, numeric(1))

pk <- peak_response(post_b, type = "irf", horizon = 8, variable = 1, shock = 1, probability = 0.68)

# Value summary statistics
expect_equal(pk$mean_value, mean(manual_peak_values),
             tolerance = 1e-10, info = "peak mean_value")
expect_equal(pk$median_value, stats::median(manual_peak_values),
             tolerance = 1e-10, info = "peak median_value")
expect_equal(pk$sd_value, stats::sd(manual_peak_values),
             tolerance = 1e-10, info = "peak sd_value")
expect_equal(pk$lower_value,
             stats::quantile(manual_peak_values, probs = 0.16, names = FALSE),
             tolerance = 1e-10, info = "peak lower_value")
expect_equal(pk$upper_value,
             stats::quantile(manual_peak_values, probs = 0.84, names = FALSE),
             tolerance = 1e-10, info = "peak upper_value")

# Horizon summary statistics
expect_equal(pk$mean_horizon, mean(manual_peak_horizons),
             tolerance = 1e-10, info = "peak mean_horizon")
expect_equal(pk$median_horizon, stats::median(manual_peak_horizons),
             tolerance = 1e-10, info = "peak median_horizon")
expect_equal(pk$sd_horizon, stats::sd(manual_peak_horizons),
             tolerance = 1e-10, info = "peak sd_horizon")
expect_equal(pk$lower_horizon,
             stats::quantile(manual_peak_horizons, probs = 0.16, names = FALSE),
             tolerance = 1e-10, info = "peak lower_horizon")
expect_equal(pk$upper_horizon,
             stats::quantile(manual_peak_horizons, probs = 0.84, names = FALSE),
             tolerance = 1e-10, info = "peak upper_horizon")

# ---- Test 2: peak_response with absolute = TRUE ----
manual_abs_peaks <- vapply(seq_len(30), function(s) {
  path <- irf_raw[1, 1, , s]
  path[which.max(abs(path))]
}, numeric(1))

pk_abs <- peak_response(post_b, type = "irf", horizon = 8, variable = 1, shock = 1, absolute = TRUE)
expect_equal(pk_abs$median_value, stats::median(manual_abs_peaks),
             tolerance = 1e-10, info = "peak absolute median_value")

# ---- Test 3: duration_response consecutive mode ----
manual_consec <- vapply(seq_len(30), function(s) {
  path <- irf_raw[1, 1, , s]
  satisfied <- path > 0
  if (!satisfied[1]) return(0)
  fail <- which(!satisfied)[1]
  if (is.na(fail)) length(satisfied) else fail - 1L
}, numeric(1))

dur_c <- duration_response(
  post_b, type = "irf", horizon = 8, variable = 1, shock = 1,
  relation = ">", value = 0, mode = "consecutive"
)
expect_equal(dur_c$mean_duration, mean(manual_consec),
             tolerance = 1e-10, info = "duration consecutive mean")
expect_equal(dur_c$median_duration, stats::median(manual_consec),
             tolerance = 1e-10, info = "duration consecutive median")

# ---- Test 4: duration_response total mode ----
manual_total <- vapply(seq_len(30), function(s) {
  sum(irf_raw[1, 1, , s] > 0)
}, numeric(1))

dur_t <- duration_response(
  post_b, type = "irf", horizon = 8, variable = 1, shock = 1,
  relation = ">", value = 0, mode = "total"
)
expect_equal(dur_t$mean_duration, mean(manual_total),
             tolerance = 1e-10, info = "duration total mean")
expect_equal(dur_t$median_duration, stats::median(manual_total),
             tolerance = 1e-10, info = "duration total median")

# ---- Test 5: half_life_response with NA handling ----
# Replicate compute_half_life: baseline = "peak", fraction = 0.5, absolute = TRUE
manual_hl <- vapply(seq_len(30), function(s) {
  path      <- irf_raw[1, 1, , s]
  eval_path <- abs(path)
  ref_idx   <- which.max(eval_path)
  ref_value <- eval_path[ref_idx]
  if (is.na(ref_value) || ref_value <= 0) return(NA_real_)
  target   <- 0.5 * ref_value
  tail_idx <- seq.int(ref_idx, length(eval_path))
  hit      <- tail_idx[eval_path[tail_idx] <= target][1]
  if (is.na(hit)) return(NA_real_)
  horizons <- 0:8
  horizons[hit] - horizons[ref_idx]
}, numeric(1))

valid_hl <- manual_hl[!is.na(manual_hl)]

hl <- half_life_response(
  post_b, type = "irf", horizon = 8, variable = 1, shock = 1,
  probability = 0.68
)

# reached_prob always testable
expect_equal(hl$reached_prob, mean(!is.na(manual_hl)),
             tolerance = 1e-10, info = "half_life reached_prob")

# Summary stats only if any draws reached half-life
if (length(valid_hl) > 0) {
  expect_equal(hl$mean_half_life, mean(valid_hl),
               tolerance = 1e-10, info = "half_life mean")
  expect_equal(hl$median_half_life, stats::median(valid_hl),
               tolerance = 1e-10, info = "half_life median")
}

# ---- Test 6: time_to_threshold with NA handling ----
manual_ttt <- vapply(seq_len(30), function(s) {
  path      <- irf_raw[1, 1, , s]
  satisfied <- path > 0
  hit       <- which(satisfied)[1]
  if (is.na(hit)) return(NA_real_)
  horizons <- 0:8
  horizons[hit]
}, numeric(1))

valid_ttt <- manual_ttt[!is.na(manual_ttt)]

ttt <- time_to_threshold(
  post_b, type = "irf", horizon = 8, variable = 1, shock = 1,
  relation = ">", value = 0
)

# reached_prob
expect_equal(ttt$reached_prob, mean(!is.na(manual_ttt)),
             tolerance = 1e-10, info = "time_to_threshold reached_prob")

# Summary stats
if (length(valid_ttt) > 0) {
  expect_equal(ttt$mean_horizon, mean(valid_ttt),
               tolerance = 1e-10, info = "time_to_threshold mean_horizon")
  expect_equal(ttt$median_horizon, stats::median(valid_ttt),
               tolerance = 1e-10, info = "time_to_threshold median_horizon")
}
