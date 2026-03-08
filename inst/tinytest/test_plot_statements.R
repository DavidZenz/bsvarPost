make_statement_irf <- function() {
  arr <- array(0, dim = c(1, 1, 3, 4), dimnames = list("y", "shock", c("0", "1", "2"), c("1", "2", "3", "4")))
  arr[1, 1, , 1] <- c(1, 1, 1)
  arr[1, 1, , 2] <- c(1, 2, 2)
  arr[1, 1, , 3] <- c(-1, 2, 3)
  arr[1, 1, , 4] <- c(2, 2, 2)
  class(arr) <- c("PosteriorIR", class(arr))
  arr
}

irf_obj <- make_statement_irf()
hyp_tbl <- hypothesis_irf(irf_obj, variable = "y", shock = "shock", horizon = 0:2, relation = ">", value = 0)

p_hyp_tbl <- plot_hypothesis(hyp_tbl)
expect_true(inherits(p_hyp_tbl, "ggplot"))

data(us_fiscal_lsuw, package = "bsvars")
set.seed(31)
post <- bsvars::estimate(bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1), S = 6, thin = 1, show_progress = FALSE)

p_hyp_model <- plot_hypothesis(post, type = "irf", variable = 1, shock = 1, horizon = 0:2, relation = ">", value = 0)
expect_true(inherits(p_hyp_model, "ggplot"))

restrictions <- list(irf_restriction(variable = 1, shock = 1, horizon = 0, sign = 1))
audit_tbl <- restriction_audit(post, restrictions = restrictions)
p_audit_tbl <- plot_restriction_audit(audit_tbl)
expect_true(inherits(p_audit_tbl, "ggplot"))

p_audit_model <- plot_restriction_audit(post, restrictions = restrictions)
expect_true(inherits(p_audit_model, "ggplot"))

expect_error(
  plot_hypothesis(audit_tbl),
  "requires a hypothesis or magnitude-audit table",
  info = "plot_hypothesis: rejects audit tables."
)

expect_error(
  plot_restriction_audit(hyp_tbl),
  "requires a restriction-audit table",
  info = "plot_restriction_audit: rejects hypothesis tables."
)
