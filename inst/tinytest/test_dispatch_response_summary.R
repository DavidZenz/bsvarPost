Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")
data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec_sv <- bsvars::specify_bsvar_sv$new(us_fiscal_lsuw, p = 1)
post_sv <- bsvars::estimate(spec_sv, S = 5, thin = 1, show_progress = FALSE)

# peak_response dispatches for PosteriorBSVARSV
result_peak <- peak_response(post_sv, horizon = 2)
expect_true(
  inherits(result_peak, "bsvar_post_tbl"),
  info = "peak_response.PosteriorBSVARSV: returns bsvar_post_tbl"
)
expect_true(
  nrow(result_peak) > 0,
  info = "peak_response.PosteriorBSVARSV: non-zero rows"
)
expect_true(
  all(c("variable", "shock", "median_value", "median_horizon") %in% names(result_peak)),
  info = "peak_response.PosteriorBSVARSV: has expected columns"
)

# duration_response dispatches for PosteriorBSVARSV
result_dur <- duration_response(post_sv, horizon = 2, relation = ">", value = 0)
expect_true(
  inherits(result_dur, "bsvar_post_tbl"),
  info = "duration_response.PosteriorBSVARSV: returns bsvar_post_tbl"
)
expect_true(
  nrow(result_dur) > 0,
  info = "duration_response.PosteriorBSVARSV: non-zero rows"
)
expect_true(
  all(c("variable", "shock", "median_duration") %in% names(result_dur)),
  info = "duration_response.PosteriorBSVARSV: has expected columns"
)

# half_life_response dispatches for PosteriorBSVARSV
result_hl <- half_life_response(post_sv, horizon = 2)
expect_true(
  inherits(result_hl, "bsvar_post_tbl"),
  info = "half_life_response.PosteriorBSVARSV: returns bsvar_post_tbl"
)
expect_true(
  nrow(result_hl) > 0,
  info = "half_life_response.PosteriorBSVARSV: non-zero rows"
)
expect_true(
  all(c("variable", "shock", "reached_prob") %in% names(result_hl)),
  info = "half_life_response.PosteriorBSVARSV: has expected columns"
)

# time_to_threshold dispatches for PosteriorBSVARSV
result_ttt <- time_to_threshold(post_sv, horizon = 2, relation = ">", value = 0)
expect_true(
  inherits(result_ttt, "bsvar_post_tbl"),
  info = "time_to_threshold.PosteriorBSVARSV: returns bsvar_post_tbl"
)
expect_true(
  nrow(result_ttt) > 0,
  info = "time_to_threshold.PosteriorBSVARSV: non-zero rows"
)
expect_true(
  all(c("variable", "shock", "reached_prob") %in% names(result_ttt)),
  info = "time_to_threshold.PosteriorBSVARSV: has expected columns"
)

# object_type attribute is set on all results
expect_true(
  !is.null(attr(result_peak, "object_type")),
  info = "peak_response.PosteriorBSVARSV: object_type attribute set"
)
expect_true(
  !is.null(attr(result_dur, "object_type")),
  info = "duration_response.PosteriorBSVARSV: object_type attribute set"
)
expect_true(
  !is.null(attr(result_hl, "object_type")),
  info = "half_life_response.PosteriorBSVARSV: object_type attribute set"
)
expect_true(
  !is.null(attr(result_ttt, "object_type")),
  info = "time_to_threshold.PosteriorBSVARSV: object_type attribute set"
)

# PosteriorIR intermediate dispatch for peak_response
ir <- bsvars::compute_impulse_responses(post_sv, horizon = 2)
result_peak_ir <- peak_response(ir)
expect_true(
  inherits(result_peak_ir, "bsvar_post_tbl"),
  info = "peak_response.PosteriorIR from SV: returns bsvar_post_tbl"
)
expect_true(
  nrow(result_peak_ir) > 0,
  info = "peak_response.PosteriorIR from SV: non-zero rows"
)

# PosteriorIR intermediate dispatch for duration_response
result_dur_ir <- duration_response(ir, relation = ">", value = 0)
expect_true(
  inherits(result_dur_ir, "bsvar_post_tbl"),
  info = "duration_response.PosteriorIR from SV: returns bsvar_post_tbl"
)

# PosteriorIR intermediate dispatch for half_life_response
result_hl_ir <- half_life_response(ir)
expect_true(
  inherits(result_hl_ir, "bsvar_post_tbl"),
  info = "half_life_response.PosteriorIR from SV: returns bsvar_post_tbl"
)

# PosteriorIR intermediate dispatch for time_to_threshold
result_ttt_ir <- time_to_threshold(ir, relation = ">", value = 0)
expect_true(
  inherits(result_ttt_ir, "bsvar_post_tbl"),
  info = "time_to_threshold.PosteriorIR from SV: returns bsvar_post_tbl"
)

# PosteriorCDM intermediate dispatch for peak_response
cdm_obj <- bsvarPost:::get_cdm_draws(post_sv, horizon = 2)
result_peak_cdm <- peak_response(cdm_obj)
expect_true(
  inherits(result_peak_cdm, "bsvar_post_tbl"),
  info = "peak_response.PosteriorCDM from SV: returns bsvar_post_tbl"
)

# PosteriorCDM intermediate dispatch for duration_response
result_dur_cdm <- duration_response(cdm_obj, relation = ">", value = 0)
expect_true(
  inherits(result_dur_cdm, "bsvar_post_tbl"),
  info = "duration_response.PosteriorCDM from SV: returns bsvar_post_tbl"
)
