Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec_sv <- bsvars::specify_bsvar_sv$new(us_fiscal_lsuw, p = 1)
post_sv <- bsvars::estimate(spec_sv, S = 5, thin = 1, show_progress = FALSE)

# hypothesis_irf dispatches for PosteriorBSVARSV
res_irf <- hypothesis_irf(post_sv, variable = 1, shock = 1, horizon = 2, relation = ">", value = 0)
expect_true(is.data.frame(res_irf))
expect_true("posterior_prob" %in% names(res_irf))
expect_true(res_irf$posterior_prob >= 0 && res_irf$posterior_prob <= 1)
expect_true(all(c("rhs_variable", "rhs_shock", "rhs_horizon", "rhs_value", "absolute") %in% names(res_irf)))

# hypothesis_cdm dispatches for PosteriorBSVARSV
res_cdm <- hypothesis_cdm(post_sv, variable = 1, shock = 1, horizon = 2, relation = ">", value = 0)
expect_true(is.data.frame(res_cdm))
expect_true("posterior_prob" %in% names(res_cdm))
expect_true(res_cdm$posterior_prob >= 0 && res_cdm$posterior_prob <= 1)

# joint_hypothesis_irf dispatches for PosteriorBSVARSV
jh_irf <- joint_hypothesis_irf(post_sv, variable = 1, shock = 1, horizon = 0:2,
                                relation = ">", value = 0)
expect_true(is.data.frame(jh_irf))
expect_true("posterior_prob" %in% names(jh_irf))
expect_true(jh_irf$posterior_prob >= 0 && jh_irf$posterior_prob <= 1)
expect_true("n_constraints" %in% names(jh_irf))
expect_true(jh_irf$n_constraints > 0)

# joint_hypothesis_cdm dispatches for PosteriorBSVARSV
jh_cdm <- joint_hypothesis_cdm(post_sv, variable = 1, shock = 1, horizon = 0:2,
                                relation = ">", value = 0)
expect_true(is.data.frame(jh_cdm))
expect_true("posterior_prob" %in% names(jh_cdm))
expect_true(jh_cdm$posterior_prob >= 0 && jh_cdm$posterior_prob <= 1)
expect_true("n_constraints" %in% names(jh_cdm))

# simultaneous_irf dispatches for PosteriorBSVARSV
sim_irf <- simultaneous_irf(post_sv, horizon = 2)
expect_true(inherits(sim_irf, "bsvar_post_tbl"))
expect_true(nrow(sim_irf) > 0)
expect_true(all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(sim_irf)))
expect_true(all(c("simultaneous_prob", "critical_value") %in% names(sim_irf)))

# simultaneous_cdm dispatches for PosteriorBSVARSV
sim_cdm <- simultaneous_cdm(post_sv, horizon = 2)
expect_true(inherits(sim_cdm, "bsvar_post_tbl"))
expect_true(nrow(sim_cdm) > 0)
expect_true(all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(sim_cdm)))
expect_true(all(c("simultaneous_prob", "critical_value") %in% names(sim_cdm)))
