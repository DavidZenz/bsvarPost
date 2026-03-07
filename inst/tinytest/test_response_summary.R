data(us_fiscal_lsuw)
set.seed(1)
spec_bsvar <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_bsvar <- estimate(spec_bsvar, S = 5, thin = 1, show_progress = FALSE)

irf_draws <- bsvars::compute_impulse_responses(post_bsvar, horizon = 4)
peak_tbl <- peak_response(post_bsvar, type = "irf", horizon = 4, variable = 1, shock = 1)
expect_true(inherits(peak_tbl, "bsvar_post_tbl"))
manual_peaks <- vapply(seq_len(dim(irf_draws)[4]), function(s) {
  path <- irf_draws[1, 1, , s]
  horizons <- 0:4
  path[which.max(path)]
}, numeric(1))
manual_horizons <- vapply(seq_len(dim(irf_draws)[4]), function(s) {
  path <- irf_draws[1, 1, , s]
  horizons <- 0:4
  horizons[which.max(path)]
}, numeric(1))
expect_equal(peak_tbl$median_value, stats::median(manual_peaks))
expect_equal(peak_tbl$median_horizon, stats::median(manual_horizons))

peak_abs_tbl <- peak_response(post_bsvar, type = "irf", horizon = 4, variable = 1, shock = 1, absolute = TRUE)
manual_abs_peaks <- vapply(seq_len(dim(irf_draws)[4]), function(s) {
  path <- irf_draws[1, 1, , s]
  path[which.max(abs(path))]
}, numeric(1))
expect_equal(peak_abs_tbl$median_value, stats::median(manual_abs_peaks))

cdm_draws <- bsvarPost:::get_cdm_draws(post_bsvar, horizon = 4)
peak_cdm_tbl <- peak_response(cdm_draws, variable = 1, shock = 1)
manual_cdm_peaks <- vapply(seq_len(dim(cdm_draws)[4]), function(s) {
  path <- cdm_draws[1, 1, , s]
  path[which.max(path)]
}, numeric(1))
expect_equal(peak_cdm_tbl$median_value, stats::median(manual_cdm_peaks))

duration_tbl <- duration_response(post_bsvar, type = "irf", horizon = 4, variable = 1, shock = 1, relation = ">", value = 0, mode = "consecutive")
manual_duration <- vapply(seq_len(dim(irf_draws)[4]), function(s) {
  path <- irf_draws[1, 1, , s]
  satisfied <- path > 0
  if (!satisfied[1]) return(0)
  fail <- which(!satisfied)[1]
  if (is.na(fail)) length(satisfied) else fail - 1L
}, numeric(1))
expect_equal(duration_tbl$median_duration, stats::median(manual_duration))

total_tbl <- duration_response(post_bsvar, type = "irf", horizon = 4, variable = 1, shock = 1, relation = ">", value = 0, mode = "total")
manual_total <- vapply(seq_len(dim(irf_draws)[4]), function(s) sum(irf_draws[1, 1, , s] > 0), numeric(1))
expect_equal(total_tbl$median_duration, stats::median(manual_total))

duration_cdm_tbl <- duration_response(post_bsvar, type = "cdm", horizon = 4, variable = 1, shock = 1, relation = ">=", value = 0, mode = "total")
manual_cdm_total <- vapply(seq_len(dim(cdm_draws)[4]), function(s) sum(cdm_draws[1, 1, , s] >= 0), numeric(1))
expect_equal(duration_cdm_tbl$median_duration, stats::median(manual_cdm_total))
