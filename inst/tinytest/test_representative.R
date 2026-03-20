data(us_fiscal_lsuw)
set.seed(1)
spec_bsvar <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_bsvar <- estimate(spec_bsvar, S = 5, thin = 1, show_progress = FALSE)

irf_draws <- bsvars::compute_impulse_responses(post_bsvar, horizon = 4)
target <- bsvarPost:::selection_target(irf_draws, center = "median")
distances <- bsvarPost:::distance_to_target(irf_draws, target, metric = "l2", standardize = "none")
expected_idx <- which.min(distances)

rep_irf <- median_target_irf(post_bsvar, horizon = 4)
expect_equal(rep_irf$draw_index, expected_idx)
expect_true(inherits(rep_irf, "RepresentativeIR"))
expect_true(inherits(summary(rep_irf), "bsvar_post_tbl"))

rep_irf_direct <- representative_irf(irf_draws, center = "median")
expect_true(inherits(rep_irf_direct, "RepresentativeIR"))
expect_equal(attr(summary(rep_irf_direct), "object_type"), "irf")

rep_irf_50 <- representative_irf(post_bsvar, horizon = 4, probability = 0.5)
rep_irf_90 <- representative_irf(post_bsvar, horizon = 4, probability = 0.9)
expect_equal(rep_irf_50$probability, 0.5)
expect_true(
  mean(rep_irf_50$target_summary$upper - rep_irf_50$target_summary$lower) <
    mean(rep_irf_90$target_summary$upper - rep_irf_90$target_summary$lower),
  info = "representative_irf: target_summary respects the requested probability."
)

rep_cdm <- median_target_cdm(post_bsvar, horizon = 4)
expect_true(inherits(rep_cdm, "RepresentativeCDM"))
cdm_draws <- cdm(post_bsvar, horizon = 4)
rep_cdm_direct <- representative_cdm(cdm_draws, center = "median")
expect_true(inherits(rep_cdm_direct, "RepresentativeCDM"))
expect_equal(attr(summary(rep_cdm_direct), "object_type"), "cdm")

expect_error(
  most_likely_admissible_irf(post_bsvar, horizon = 4),
  pattern = "PosteriorBSVARSIGN",
  info = "most_likely_admissible_irf: unsupported classes error clearly."
)

data(optimism)
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
set.seed(1)
spec_sign <- specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
post_sign <- estimate(spec_sign, S = 5, thin = 1, show_progress = FALSE)

scores <- bsvarPost:::compute_posterior_kernel(post_sign)
rep_sign <- most_likely_admissible_irf(post_sign, horizon = 4)
expect_equal(rep_sign$score, max(scores))
expect_true(rep_sign$draw_index %in% which(scores == max(scores)))
expect_true(inherits(summary(rep_sign), "bsvar_post_tbl"))

rep_sign_cdm <- most_likely_admissible_cdm(post_sign, horizon = 4)
expect_equal(rep_sign_cdm$method, "most_likely_admissible")
expect_true(inherits(summary(rep_sign_cdm), "bsvar_post_tbl"))

expect_error(
  representative_irf(list()),
  pattern = "PosteriorIR",
  info = "representative_irf: unsupported classes get a clear error."
)

expect_error(
  representative_cdm(list()),
  pattern = "PosteriorCDM",
  info = "representative_cdm: unsupported classes get a clear error."
)

expect_error(
  representative_irf(post_bsvar, horizon = -1),
  pattern = "non-negative",
  info = "representative_irf: invalid horizon is rejected."
)

expect_error(
  representative_cdm(post_bsvar, horizon = 4, probability = 1),
  pattern = "strictly between 0 and 1",
  info = "representative_cdm: invalid probability is rejected."
)

expect_error(
  bsvarPost:::bsvarsigns_native_symbol("_bsvarSIGNs_missing_symbol"),
  pattern = "upstream native interface",
  info = "bsvarSIGNs native bridge: missing symbols fail with actionable message."
)

expect_error(
  bsvarPost:::compute_posterior_kernel(structure(list(), class = "PosteriorBSVARSIGN")),
  pattern = "missing field",
  info = "compute_posterior_kernel: malformed sign posterior objects are rejected early."
)
