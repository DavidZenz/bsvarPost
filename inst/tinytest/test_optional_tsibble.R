if (!requireNamespace("tsibble", quietly = TRUE)) {
  exit_file("tsibble not installed -- skipping tsibble smoke tests")
}

Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")
data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)

# as_tsibble_post on tidy_irf output (horizon index)
irf_tbl <- tidy_irf(post, horizon = 3)
ts_irf <- as_tsibble_post(irf_tbl)
expect_true(inherits(ts_irf, "tbl_ts"), info = "as_tsibble_post on tidy_irf output returns tbl_ts")
expect_true(nrow(ts_irf) > 0, info = "as_tsibble_post on tidy_irf returns non-empty result")

# as_tsibble_post on tidy_shocks output (time index)
shocks_tbl <- tidy_shocks(post)
ts_shocks <- as_tsibble_post(shocks_tbl)
expect_true(inherits(ts_shocks, "tbl_ts"), info = "as_tsibble_post on tidy_shocks output returns tbl_ts")
expect_true(nrow(ts_shocks) > 0, info = "as_tsibble_post on tidy_shocks returns non-empty result")
expect_true(is.numeric(ts_shocks$time), info = "as_tsibble_post coerces numeric-like shock time indexes")

# as_tsibble_post on tidy_hd output (time index)
hd_tbl <- tidy_hd(post)
ts_hd <- as_tsibble_post(hd_tbl)
expect_true(inherits(ts_hd, "tbl_ts"), info = "as_tsibble_post on tidy_hd output returns tbl_ts")
expect_true(nrow(ts_hd) > 0, info = "as_tsibble_post on tidy_hd returns non-empty result")
expect_true(is.numeric(ts_hd$time), info = "as_tsibble_post coerces numeric-like HD time indexes")
