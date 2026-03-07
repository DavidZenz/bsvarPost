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

rep_cdm <- median_target_cdm(post_bsvar, horizon = 4)
expect_true(inherits(rep_cdm, "RepresentativeCDM"))

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
