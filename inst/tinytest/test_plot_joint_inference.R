make_joint_plot_irf <- function() {
  arr <- array(0, dim = c(1, 1, 2, 3), dimnames = list("y", "shock", c("0", "1"), c("1", "2", "3")))
  arr[1, 1, , 1] <- c(1, 1)
  arr[1, 1, , 2] <- c(2, 2)
  arr[1, 1, , 3] <- c(-1, 0.5)
  class(arr) <- c("PosteriorIR", class(arr))
  arr
}

irf_obj <- make_joint_plot_irf()
sim_tbl <- simultaneous_irf(irf_obj, variable = "y", shock = "shock", probability = 0.68)
joint_tbl <- joint_hypothesis_irf(irf_obj, variable = "y", shock = "shock", horizon = c(0, 1), relation = ">", value = 0)

p_sim_tbl <- plot_simultaneous(sim_tbl)
p_joint_tbl <- plot_joint_hypothesis(joint_tbl)

expect_true(inherits(p_sim_tbl, "ggplot"))
expect_true(inherits(p_joint_tbl, "ggplot"))

data(us_fiscal_lsuw, package = "bsvars")
set.seed(29)
post <- bsvars::estimate(bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1), S = 6, thin = 1, show_progress = FALSE)

p_sim_model <- plot_simultaneous(post, type = "irf", horizon = 4, variable = 1, shock = 1)
p_joint_model <- plot_joint_hypothesis(post, type = "irf", variable = 1, shock = 1, horizon = 0:1, relation = ">", value = 0)

expect_true(inherits(p_sim_model, "ggplot"))
expect_true(inherits(p_joint_model, "ggplot"))

expect_error(
  plot_simultaneous(joint_tbl),
  "requires a simultaneous-band table",
  info = "plot_simultaneous: rejects non-simultaneous objects."
)

expect_error(
  plot_joint_hypothesis(sim_tbl),
  "requires a joint-hypothesis table",
  info = "plot_joint_hypothesis: rejects non-joint objects."
)
