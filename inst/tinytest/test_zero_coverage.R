Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# -----------------------------------------------------------------------
# test_zero_coverage.R
# Tests for the 3 exported functions with zero test references:
#   1. compare_forecast
#   2. most_likely_admissible_cdm
#   3. apr_gen_mats
# -----------------------------------------------------------------------

# --- Fixture: PosteriorBSVAR (cheaper than SV for most_likely_admissible_cdm) ---
data(us_fiscal_lsuw, package = "bsvars")
set.seed(42)
spec_base <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_a <- bsvars::estimate(spec_base, S = 5, thin = 1, show_progress = FALSE)
post_b <- bsvars::estimate(spec_base, S = 5, thin = 1, show_progress = FALSE)

# -----------------------------------------------------------------------
# 1. compare_forecast -- structural column check
# -----------------------------------------------------------------------
cmp_fc <- compare_forecast(base = post_a, alt = post_b, horizon = 3)
expect_true(inherits(cmp_fc, "bsvar_post_tbl"),
  info = "compare_forecast: returns bsvar_post_tbl")
expect_true(nrow(cmp_fc) > 0,
  info = "compare_forecast: nrow > 0")
expect_true("model" %in% names(cmp_fc),
  info = "compare_forecast: has model column")
expect_equal(sort(unique(cmp_fc$model)), c("alt", "base"),
  info = "compare_forecast: model values are base and alt")
expect_true(isTRUE(attr(cmp_fc, "compare")),
  info = "compare_forecast: compare attribute is TRUE")
expect_true(all(c("variable", "horizon", "median", "lower", "upper", "model") %in% names(cmp_fc)),
  info = "compare_forecast: has all expected columns")
expect_true(all(cmp_fc$horizon >= 0),
  info = "compare_forecast: horizons are non-negative")
expect_equal(attr(cmp_fc, "object_type"), "forecast",
  info = "compare_forecast: object_type is forecast")

# -----------------------------------------------------------------------
# 2. most_likely_admissible_cdm -- requires PosteriorBSVARSIGN
# -----------------------------------------------------------------------

# First verify it errors on non-SIGN objects
expect_error(
  most_likely_admissible_cdm(post_a, horizon = 2),
  pattern = "PosteriorBSVARSIGN",
  info = "most_likely_admissible_cdm: errors on non-SIGN object"
)

# Now test with PosteriorBSVARSIGN
data(optimism, package = "bsvarSIGNs")
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
set.seed(1)
spec_sign <- bsvarSIGNs::specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
post_sign <- bsvars::estimate(spec_sign, S = 5, thin = 1, show_progress = FALSE)

mla_cdm <- most_likely_admissible_cdm(post_sign, horizon = 2)
expect_true(inherits(mla_cdm, "RepresentativeCDM"),
  info = "most_likely_admissible_cdm: returns RepresentativeCDM")
expect_true(inherits(mla_cdm, "RepresentativeResponse"),
  info = "most_likely_admissible_cdm: inherits RepresentativeResponse")
expect_true(is.integer(mla_cdm$draw_index),
  info = "most_likely_admissible_cdm: draw_index is integer")
expect_true(mla_cdm$draw_index >= 1 && mla_cdm$draw_index <= 5,
  info = "most_likely_admissible_cdm: draw_index in [1, S]")
expect_equal(mla_cdm$method, "most_likely_admissible",
  info = "most_likely_admissible_cdm: method is most_likely_admissible")
expect_true(is.array(mla_cdm$representative_draw),
  info = "most_likely_admissible_cdm: representative_draw is array")

# mirror most_likely_admissible_irf: same draw_index selected by kernel score
mla_irf <- most_likely_admissible_irf(post_sign, horizon = 2)
expect_equal(mla_cdm$draw_index, mla_irf$draw_index,
  info = "most_likely_admissible_cdm: same draw_index as most_likely_admissible_irf")

# summary returns bsvar_post_tbl
mla_cdm_summary <- summary(mla_cdm)
expect_true(inherits(mla_cdm_summary, "bsvar_post_tbl"),
  info = "most_likely_admissible_cdm summary: returns bsvar_post_tbl")

# -----------------------------------------------------------------------
# 3. apr_gen_mats -- test the requireNamespace error path
# -----------------------------------------------------------------------
if (!requireNamespace("APRScenario", quietly = TRUE)) {
  # APRScenario is NOT available: verify informative error
  err <- tryCatch(
    apr_gen_mats(posterior = post_a, specification = spec_base),
    error = function(e) e
  )
  expect_true(inherits(err, "error"),
    info = "apr_gen_mats: produces error when APRScenario absent")
  expect_true(grepl("APRScenario", conditionMessage(err)),
    info = "apr_gen_mats: error message mentions APRScenario package")
} else {
  # APRScenario IS available: test no-error execution
  result <- apr_gen_mats(posterior = post_a, specification = spec_base, max_cores = 1)
  expect_true(is.list(result),
    info = "apr_gen_mats: returns list when APRScenario is available")
}
