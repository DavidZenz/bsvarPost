Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")
data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec_sv <- bsvars::specify_bsvar_sv$new(us_fiscal_lsuw, p = 1)
post_sv <- bsvars::estimate(spec_sv, S = 5, thin = 1, show_progress = FALSE)

# representative_irf dispatches for PosteriorBSVARSV
result_rep_irf <- representative_irf(post_sv, horizon = 2)
expect_true(
  is.list(result_rep_irf),
  info = "representative_irf.PosteriorBSVARSV: returns list"
)
expect_true(
  !is.null(result_rep_irf$draw_index),
  info = "representative_irf.PosteriorBSVARSV: has draw_index"
)
expect_true(
  !is.null(result_rep_irf$method),
  info = "representative_irf.PosteriorBSVARSV: has method"
)
expect_equal(
  result_rep_irf$method,
  "median_target",
  info = "representative_irf.PosteriorBSVARSV: default method is median_target"
)
expect_true(
  inherits(result_rep_irf, "RepresentativeIR"),
  info = "representative_irf.PosteriorBSVARSV: inherits RepresentativeIR"
)
expect_true(
  inherits(result_rep_irf, "RepresentativeResponse"),
  info = "representative_irf.PosteriorBSVARSV: inherits RepresentativeResponse"
)

# representative_cdm dispatches for PosteriorBSVARSV
result_rep_cdm <- representative_cdm(post_sv, horizon = 2)
expect_true(
  is.list(result_rep_cdm),
  info = "representative_cdm.PosteriorBSVARSV: returns list"
)
expect_true(
  !is.null(result_rep_cdm$draw_index),
  info = "representative_cdm.PosteriorBSVARSV: has draw_index"
)
expect_true(
  !is.null(result_rep_cdm$method),
  info = "representative_cdm.PosteriorBSVARSV: has method"
)
expect_equal(
  result_rep_cdm$method,
  "median_target",
  info = "representative_cdm.PosteriorBSVARSV: default method is median_target"
)
expect_true(
  inherits(result_rep_cdm, "RepresentativeCDM"),
  info = "representative_cdm.PosteriorBSVARSV: inherits RepresentativeCDM"
)

# median_target_irf dispatches for PosteriorBSVARSV
result_mt_irf <- median_target_irf(post_sv, horizon = 2)
expect_true(
  !is.null(result_mt_irf$draw_index),
  info = "median_target_irf.PosteriorBSVARSV: has draw_index"
)
expect_equal(
  result_mt_irf$method,
  "median_target",
  info = "median_target_irf.PosteriorBSVARSV: method == median_target"
)
expect_true(
  inherits(result_mt_irf, "RepresentativeIR"),
  info = "median_target_irf.PosteriorBSVARSV: inherits RepresentativeIR"
)

# median_target_cdm dispatches for PosteriorBSVARSV
result_mt_cdm <- median_target_cdm(post_sv, horizon = 2)
expect_true(
  !is.null(result_mt_cdm$draw_index),
  info = "median_target_cdm.PosteriorBSVARSV: has draw_index"
)
expect_equal(
  result_mt_cdm$method,
  "median_target",
  info = "median_target_cdm.PosteriorBSVARSV: method == median_target"
)
expect_true(
  inherits(result_mt_cdm, "RepresentativeCDM"),
  info = "median_target_cdm.PosteriorBSVARSV: inherits RepresentativeCDM"
)

# draw_index is a valid integer within draw range (S = 5)
expect_true(
  result_mt_irf$draw_index >= 1L && result_mt_irf$draw_index <= 5L,
  info = "median_target_irf.PosteriorBSVARSV: draw_index in valid range"
)
expect_true(
  result_mt_cdm$draw_index >= 1L && result_mt_cdm$draw_index <= 5L,
  info = "median_target_cdm.PosteriorBSVARSV: draw_index in valid range"
)

# summary() produces bsvar_post_tbl
expect_true(
  inherits(summary(result_rep_irf), "bsvar_post_tbl"),
  info = "summary.RepresentativeIR on PosteriorBSVARSV result: returns bsvar_post_tbl"
)
expect_true(
  inherits(summary(result_rep_cdm), "bsvar_post_tbl"),
  info = "summary.RepresentativeCDM on PosteriorBSVARSV result: returns bsvar_post_tbl"
)

# PosteriorIR intermediate dispatch works
ir <- bsvars::compute_impulse_responses(post_sv, horizon = 2)
result_from_ir <- representative_irf(ir)
expect_true(
  inherits(result_from_ir, "RepresentativeIR"),
  info = "representative_irf.PosteriorIR from SV posterior: inherits RepresentativeIR"
)
