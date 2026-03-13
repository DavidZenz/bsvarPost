make_joint_irf <- function() {
  arr <- array(0, dim = c(1, 1, 2, 3), dimnames = list("y", "shock", c("0", "1"), c("1", "2", "3")))
  arr[1, 1, , 1] <- c(1, 1)
  arr[1, 1, , 2] <- c(2, 2)
  arr[1, 1, , 3] <- c(-1, 0.5)
  class(arr) <- c("PosteriorIR", class(arr))
  arr
}

make_identical_cdm <- function() {
  arr <- array(3, dim = c(1, 1, 2, 4), dimnames = list("y", "shock", c("0", "1"), c("1", "2", "3", "4")))
  class(arr) <- c("PosteriorCDM", class(arr))
  arr
}

irf_obj <- make_joint_irf()
cdm_obj <- make_identical_cdm()

joint_irf <- joint_hypothesis_irf(irf_obj, variable = "y", shock = "shock", horizon = c(0, 1), relation = ">", value = 0)
expect_true(inherits(joint_irf, "bsvar_post_tbl"))
expect_equal(joint_irf$posterior_prob[[1]], 2 / 3)
expect_equal(joint_irf$n_constraints[[1]], 2)

sim_cdm <- simultaneous_cdm(cdm_obj, variables = "y", shocks = "shock", probability = 0.68)
expect_true(inherits(sim_cdm, "bsvar_post_tbl"))
expect_true(all(sim_cdm$lower == sim_cdm$median))
expect_true(all(sim_cdm$upper == sim_cdm$median))

data(us_fiscal_lsuw, package = "bsvars")
set.seed(23)
post <- bsvars::estimate(bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1), S = 6, thin = 1, show_progress = FALSE)

sim_irf_model <- simultaneous_irf(post, horizon = 4, variables = 1, shocks = 1)
expect_true(all(c("lower", "median", "upper", "critical_value") %in% names(sim_irf_model)))

joint_cdm_model <- joint_hypothesis_cdm(post, variable = 1, shock = 1, horizon = c(0, 1), relation = ">", value = 0)
expect_true(all(c("posterior_prob", "n_constraints") %in% names(joint_cdm_model)))
