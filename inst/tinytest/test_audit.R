data(us_fiscal_lsuw)
set.seed(1)
spec_bsvar <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_bsvar <- estimate(spec_bsvar, S = 5, thin = 1, show_progress = FALSE)

mag_irf <- magnitude_audit(post_bsvar, type = "irf", variable = 1, shock = 1, horizon = 2, relation = ">", value = 0)
hyp_irf <- hypothesis_irf(post_bsvar, variable = 1, shock = 1, horizon = 2, relation = ">", value = 0)
expect_equal(mag_irf$posterior_prob, hyp_irf$posterior_prob)
expect_equal(mag_irf$audit_type, "magnitude")

mag_cdm <- magnitude_audit(post_bsvar, type = "cdm", variable = 1, shock = 1, horizon = 2, relation = "<=", value = 0)
hyp_cdm <- hypothesis_cdm(post_bsvar, variable = 1, shock = 1, horizon = 2, relation = "<=", value = 0)
expect_equal(mag_cdm$posterior_prob, hyp_cdm$posterior_prob)

explicit_audit <- restriction_audit(post_bsvar, restrictions = list(
  irf_restriction(variable = 1, shock = 1, horizon = 2, sign = 1),
  structural_restriction(variable = 1, shock = 1, sign = 1)
))
expect_true(inherits(explicit_audit, "bsvar_post_tbl"))
expect_equal(nrow(explicit_audit), 2)
expect_true(all(explicit_audit$posterior_prob >= 0 & explicit_audit$posterior_prob <= 1))

data(optimism)
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
set.seed(1)
spec_sign <- specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
post_sign <- estimate(spec_sign, S = 5, thin = 1, show_progress = FALSE)

default_audit <- restriction_audit(post_sign, zero_tol = 1e-6)
expect_true(any(default_audit$restriction_type == "irf_zero"))
expect_true(any(default_audit$restriction_type == "irf_sign"))
expect_true(all(default_audit$posterior_prob >= 0 & default_audit$posterior_prob <= 1))

manual_zero <- bsvars::compute_impulse_responses(post_sign, horizon = 1, standardise = FALSE)
expected_zero_prob <- mean(abs(manual_zero[1, 1, 1, ]) <= 1e-6)
zero_row <- default_audit[default_audit$restriction_type == "irf_zero", ][1, ]
expect_equal(zero_row$posterior_prob, expected_zero_prob)

narrative_draws <- array(c(1, -1, 2, 1, 0.5, 0.2), dim = c(1, 3, 2))
reduced_irf <- array(1, dim = c(1, 1, 1, 2))
narrative <- narrative_restriction(start = 1, periods = 2, type = "S", sign = 1, shock = 1)
narrative_tbl <- bsvarPost:::audit_narrative_restriction(narrative, narrative_draws, reduced_irf, p = 0)
expect_equal(narrative_tbl$posterior_prob, 0.5)
