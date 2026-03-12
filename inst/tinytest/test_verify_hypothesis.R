Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# ---- PosteriorBSVAR fixture (S=30) ----
data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b  <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b  <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)
irf_raw <- bsvars::compute_impulse_responses(post_b, horizon = 8)

# ---- Test 1: All 5 relations for hypothesis_irf threshold ----
# variable=1, shock=1, horizon=2 (array index 3: horizon 0 = index 1)
raw_values <- irf_raw[1, 1, 3, ]

for (rel in c(">", ">=", "<", "<=", "==")) {
  manual_prob <- switch(
    rel,
    ">"  = mean(raw_values > 0),
    ">=" = mean(raw_values >= 0),
    "<"  = mean(raw_values < 0),
    "<=" = mean(raw_values <= 0),
    "==" = mean(raw_values == 0)
  )
  result <- hypothesis_irf(
    post_b,
    variable = 1, shock = 1, horizon = 2,
    relation = rel, value = 0
  )
  expect_equal(
    result$posterior_prob, manual_prob,
    tolerance = 1e-10,
    info = paste("hypothesis_irf relation", rel)
  )
}

# ---- Test 2: Pairwise comparison hypothesis_irf ----
# Compare IRF[1,1,h=2] > IRF[1,1,h=0]
lhs <- irf_raw[1, 1, 3, ]  # horizon 2
rhs <- irf_raw[1, 1, 1, ]  # horizon 0
manual_pair_prob <- mean(lhs > rhs)
pair_result <- hypothesis_irf(
  post_b,
  variable = 1, shock = 1, horizon = 2,
  relation = ">",
  compare_to = list(variable = 1, shock = 1, horizon = 0)
)
expect_equal(
  pair_result$posterior_prob, manual_pair_prob,
  tolerance = 1e-10,
  info = "pairwise hypothesis_irf"
)

# ---- Test 3: absolute = TRUE hypothesis_irf ----
raw_abs        <- abs(irf_raw[1, 1, 3, ])
manual_abs_prob <- mean(raw_abs > 0.01)
abs_result <- hypothesis_irf(
  post_b,
  variable = 1, shock = 1, horizon = 2,
  relation = ">", value = 0.01, absolute = TRUE
)
expect_equal(
  abs_result$posterior_prob, manual_abs_prob,
  tolerance = 1e-10,
  info = "absolute hypothesis_irf"
)

# ---- Test 4: hypothesis_cdm posterior probabilities ----
cdm_draws  <- bsvarPost:::get_cdm_draws(post_b, horizon = 8)
raw_cdm    <- cdm_draws[1, 1, 3, ]  # variable 1, shock 1, horizon 2

# Test "<=" relation
manual_cdm_prob_le <- mean(raw_cdm <= 0)
cdm_result_le <- hypothesis_cdm(
  post_b,
  variable = 1, shock = 1, horizon = 2,
  relation = "<=", value = 0
)
expect_equal(
  cdm_result_le$posterior_prob, manual_cdm_prob_le,
  tolerance = 1e-10,
  info = "hypothesis_cdm <= relation"
)

# Test ">" relation
manual_cdm_prob_gt <- mean(raw_cdm > 0)
cdm_result_gt <- hypothesis_cdm(
  post_b,
  variable = 1, shock = 1, horizon = 2,
  relation = ">", value = 0
)
expect_equal(
  cdm_result_gt$posterior_prob, manual_cdm_prob_gt,
  tolerance = 1e-10,
  info = "hypothesis_cdm > relation"
)

# ---- Test 5: Multi-variable hypothesis_irf ----
manual_probs <- c(
  mean(irf_raw[1, 1, 3, ] > 0),
  mean(irf_raw[2, 1, 3, ] > 0)
)
multi_result <- hypothesis_irf(
  post_b,
  variable = 1:2, shock = 1, horizon = 2,
  relation = ">", value = 0
)
expect_equal(
  multi_result$posterior_prob, manual_probs,
  tolerance = 1e-10,
  info = "multi-variable hypothesis_irf"
)
