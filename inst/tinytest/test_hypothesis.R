data(us_fiscal_lsuw)
set.seed(1)
spec_bsvar <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_bsvar <- estimate(spec_bsvar, S = 5, thin = 1, show_progress = FALSE)

irf_draws <- bsvars::compute_impulse_responses(post_bsvar, horizon = 4)
manual_irf <- irf_draws[1, 1, 3, ]
expected_prob <- mean(manual_irf > 0)
res_irf <- hypothesis_irf(post_bsvar, variable = 1, shock = 1, horizon = 2, relation = ">", value = 0)
expect_equal(res_irf$posterior_prob, expected_prob)
expect_true(all(c("rhs_variable", "rhs_shock", "rhs_horizon", "rhs_value", "absolute") %in% names(res_irf)))

pair_res <- hypothesis_irf(
  post_bsvar,
  variable = 1:2,
  shock = 1,
  horizon = 2,
  relation = ">",
  compare_to = list(variable = 1, shock = 1, horizon = 0)
)
manual_pair <- irf_draws[1:2, 1, 3, , drop = FALSE] - array(irf_draws[1, 1, 1, ], dim = c(2, 1, 1, dim(irf_draws)[4]))
expect_equal(pair_res$posterior_prob, c(mean(manual_pair[1, 1, 1, ] > 0), mean(manual_pair[2, 1, 1, ] > 0)))
expect_equal(pair_res$rhs_horizon, c(0, 0))

abs_draws <- hypothesis_irf(
  post_bsvar,
  variable = 1,
  shock = 1,
  horizon = 2,
  relation = ">=",
  value = 0,
  absolute = TRUE,
  draws = TRUE
)
expect_true(isTRUE(attr(abs_draws, "draws")))
expect_equal(abs_draws$satisfied, abs(abs_draws$gap) >= 0)

cdm_draws <- bsvarPost:::get_cdm_draws(post_bsvar, horizon = 4)
manual_cdm <- cdm_draws[1, 1, 3, ]
res_cdm <- hypothesis_cdm(post_bsvar, variable = 1, shock = 1, horizon = 2, relation = "<=", value = 0)
expect_equal(res_cdm$posterior_prob, mean(manual_cdm <= 0))

data(optimism)
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
set.seed(1)
spec_sign <- specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
post_sign <- estimate(spec_sign, S = 5, thin = 1, show_progress = FALSE)

sign_res <- hypothesis_irf(post_sign, variable = 2, shock = 1, horizon = 0, relation = ">", value = 0)
sign_irf_draws <- bsvars::compute_impulse_responses(post_sign, horizon = 1, standardise = FALSE)
expect_equal(sign_res$posterior_prob, mean(sign_irf_draws[2, 1, 1, ] > 0))
