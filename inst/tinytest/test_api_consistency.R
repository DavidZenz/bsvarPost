# test_api_consistency.R
# Tests for Phase 6 API consistency additions:
#   - deprecate_arg() helper
#   - resolve_horizon() helper
#   - Dimension assertions in set_*_dimnames()
#   - Column validation in new_bsvar_post_tbl()
#   - validate_model_compatibility() in compare functions
#   - Return type consistency (bsvar_post_tbl) for tidy_*, compare_*, hypothesis_* families
#   - Deprecation warnings for old singular variable/shock params

library(bsvarPost)

# ---- deprecate_arg helper ---------------------------------------------------

# Old arg provided: should warn with "deprecated"
expect_warning(
  bsvarPost:::deprecate_arg(NULL, "old_val", "old_name", "new_name", "test_fn"),
  pattern = "deprecated",
  info = "deprecate_arg: fires warning when old_val is non-NULL"
)

# Old arg provided with NULL new_val: returns old_val
expect_equal(
  suppressWarnings(
    bsvarPost:::deprecate_arg(NULL, "old_val", "old_name", "new_name", "test_fn")
  ),
  "old_val",
  info = "deprecate_arg: returns old_val when new_val is NULL"
)

# New arg provided with NULL old_val: no warning, returns new_val
expect_equal(
  bsvarPost:::deprecate_arg("new_val", NULL, "old_name", "new_name", "test_fn"),
  "new_val",
  info = "deprecate_arg: returns new_val when old_val is NULL (no warning)"
)

# Both provided: new wins (old still triggers warning)
expect_warning(
  result_both <- bsvarPost:::deprecate_arg("new_val", "old_val", "old_name", "new_name", "test_fn"),
  pattern = "deprecated",
  info = "deprecate_arg: warns when both provided"
)
expect_equal(
  result_both,
  "new_val",
  info = "deprecate_arg: new_val wins when both are provided"
)

# ---- resolve_horizon helper -------------------------------------------------

expect_equal(
  bsvarPost:::resolve_horizon(NULL),
  20L,
  info = "resolve_horizon: NULL -> 20L (business-cycle default)"
)
expect_equal(
  bsvarPost:::resolve_horizon(5),
  5L,
  info = "resolve_horizon: explicit value passes through as integer"
)
expect_equal(
  bsvarPost:::resolve_horizon(NULL, default = 30L),
  30L,
  info = "resolve_horizon: custom default respected"
)
expect_error(
  bsvarPost:::resolve_horizon(-1),
  pattern = "non-negative",
  info = "resolve_horizon: negative value triggers validate_horizon error"
)

# ---- validate_horizon includes received value in error ----------------------

expect_error(
  bsvarPost:::validate_horizon(-1),
  pattern = "Received: -1",
  info = "validate_horizon: error includes received value for negative"
)
expect_error(
  bsvarPost:::validate_horizon(2.5),
  pattern = "Received: 2.5",
  info = "validate_horizon: error includes received value for non-integer"
)

# ---- validate_probability includes received value in error ------------------

expect_error(
  bsvarPost:::validate_probability(2),
  pattern = "Received: 2",
  info = "validate_probability: error includes received value for >1"
)
expect_error(
  bsvarPost:::validate_probability(-0.5),
  pattern = "Received: -0.5",
  info = "validate_probability: error includes received value for negative"
)

# ---- Dimension assertions in set_*_dimnames ---------------------------------

expect_error(
  bsvarPost:::set_response_dimnames(matrix(1:4, 2, 2)),
  pattern = "4-dimensional",
  info = "set_response_dimnames: rejects non-4D input"
)
expect_error(
  bsvarPost:::set_time_dimnames(matrix(1:4, 2, 2)),
  pattern = "3-dimensional",
  info = "set_time_dimnames: rejects non-3D input"
)
expect_error(
  bsvarPost:::set_hd_dimnames(matrix(1:4, 2, 2)),
  pattern = "4-dimensional",
  info = "set_hd_dimnames: rejects non-4D input"
)

# ---- new_bsvar_post_tbl column validation -----------------------------------

expect_error(
  bsvarPost:::new_bsvar_post_tbl(data.frame(x = 1), "irf"),
  pattern = "missing required columns",
  info = "new_bsvar_post_tbl: errors on missing required columns"
)

# Valid case: has model column (object_type is stored as attribute, not column)
valid_df <- data.frame(model = "m1", variable = "x",
                       stringsAsFactors = FALSE)
valid_result <- bsvarPost:::new_bsvar_post_tbl(valid_df, "irf")
expect_true(
  inherits(valid_result, "bsvar_post_tbl"),
  info = "new_bsvar_post_tbl: sets bsvar_post_tbl class on valid input"
)

# ---- validate_model_compatibility -------------------------------------------

# Incompatible variable names should error
fake_r1 <- data.frame(variable = c("x", "y"), value = 1:2, stringsAsFactors = FALSE)
fake_r2 <- data.frame(variable = c("a", "b"), value = 3:4, stringsAsFactors = FALSE)
expect_error(
  bsvarPost:::validate_model_compatibility(list(fake_r1, fake_r2), "compare_test"),
  pattern = "incompatible variable names",
  info = "validate_model_compatibility: errors on mismatched variable names"
)

# Compatible variable names should pass silently
fake_r3 <- data.frame(variable = c("x", "y"), value = 5:6, stringsAsFactors = FALSE)
expect_silent(
  bsvarPost:::validate_model_compatibility(list(fake_r1, fake_r3), "compare_test"),
  info = "validate_model_compatibility: silent on matching variable names"
)

# Incompatible horizon ranges should error
fake_h1 <- data.frame(variable = "x", horizon = 1:3, value = 1:3,
                      stringsAsFactors = FALSE)
fake_h2 <- data.frame(variable = "x", horizon = 1:5, value = 1:5,
                      stringsAsFactors = FALSE)
expect_error(
  bsvarPost:::validate_model_compatibility(list(fake_h1, fake_h2), "compare_test"),
  pattern = "incompatible horizon ranges",
  info = "validate_model_compatibility: errors on mismatched horizon ranges"
)

# ---- Return type consistency (bsvar_post_tbl) for function families ---------

data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
set.seed(42)
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

# tidy_* family
tidy_result <- tidy_irf(post, horizon = 3, probability = 0.90)
expect_true(
  inherits(tidy_result, "bsvar_post_tbl"),
  info = "tidy_irf must return bsvar_post_tbl"
)

# compare_* family
set.seed(99)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
compare_result <- compare_irf(post, post2, horizon = 3, probability = 0.90)
expect_true(
  inherits(compare_result, "bsvar_post_tbl"),
  info = "compare_irf must return bsvar_post_tbl"
)

# hypothesis_* family (horizon is required for hypothesis_irf)
hyp_result <- hypothesis_irf(post, horizon = 3, probability = 0.90)
expect_true(
  inherits(hyp_result, "bsvar_post_tbl"),
  info = "hypothesis_irf must return bsvar_post_tbl"
)

# ---- Deprecation warnings for singular variable/shock params ----------------

# simultaneous_irf with old singular param should warn
irf_draws <- bsvars::compute_impulse_responses(post, horizon = 3)
class(irf_draws) <- c("PosteriorIR", class(irf_draws))
expect_warning(
  simultaneous_irf(irf_draws, variable = "ttr", shock = "ttr"),
  pattern = "deprecated",
  info = "simultaneous_irf: fires deprecation warning for old singular params"
)

# simultaneous_irf with new plural params should NOT warn
expect_silent(
  simultaneous_irf(irf_draws, variables = "ttr", shocks = "ttr"),
  info = "simultaneous_irf: no warning when using new plural params"
)

# peak_response with old singular param should warn
expect_warning(
  peak_response(post, horizon = 3, variable = "gdp", shock = "gdp"),
  pattern = "deprecated",
  info = "peak_response: fires deprecation warning for old singular params"
)

# peak_response with new plural params should NOT warn and return correct type
pk_result <- peak_response(post, horizon = 3, variables = "gdp", shocks = "gdp")
expect_true(
  inherits(pk_result, "bsvar_post_tbl"),
  info = "peak_response: returns bsvar_post_tbl with new plural params"
)
