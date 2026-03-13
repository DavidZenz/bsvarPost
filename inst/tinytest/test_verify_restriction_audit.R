Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# ===========================================================================
# PosteriorBSVAR fixture (S = 30)
# ===========================================================================
data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b  <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b  <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)
irf_raw <- bsvars::compute_impulse_responses(post_b, horizon = 4)

# ---------------------------------------------------------------------------
# Test 1 -- Explicit sign restriction (IRF, positive)
# ---------------------------------------------------------------------------
# Manual: variable=1, shock=1, horizon=0 => array index [1, 1, 1, ]
manual_sign_prob <- mean(irf_raw[1, 1, 1, ] > 0)

audit <- restriction_audit(
  post_b,
  restrictions = list(
    irf_restriction(variable = 1, shock = 1, horizon = 0, sign = 1)
  )
)

expect_equal(
  audit$posterior_prob,
  manual_sign_prob,
  tolerance = 1e-10,
  info = "sign restriction (positive) probability matches manual computation"
)

# ---------------------------------------------------------------------------
# Test 2 -- Explicit sign restriction (IRF, negative)
# ---------------------------------------------------------------------------
# Manual: variable=2, shock=1, horizon=0, sign=-1 => array index [2, 1, 1, ]
manual_neg_prob <- mean(irf_raw[2, 1, 1, ] < 0)

audit_neg <- restriction_audit(
  post_b,
  restrictions = list(
    irf_restriction(variable = 2, shock = 1, horizon = 0, sign = -1)
  )
)

expect_equal(
  audit_neg$posterior_prob,
  manual_neg_prob,
  tolerance = 1e-10,
  info = "sign restriction (negative) probability matches manual computation"
)

# ---------------------------------------------------------------------------
# Test 3 -- Explicit structural restriction
# ---------------------------------------------------------------------------
# Extract structural matrix B draws: dimensions [N, N, S]
B_draws <- post_b$posterior$B
manual_struct_prob <- mean(B_draws[1, 1, ] > 0)

audit_struct <- restriction_audit(
  post_b,
  restrictions = list(
    structural_restriction(variable = 1, shock = 1, sign = 1)
  )
)

expect_equal(
  audit_struct$posterior_prob,
  manual_struct_prob,
  tolerance = 1e-10,
  info = "structural restriction probability matches manual computation"
)

# ---------------------------------------------------------------------------
# Test 4 -- Multiple restrictions at once
# ---------------------------------------------------------------------------
# Three restrictions: two IRF sign + one structural
restrictions_multi <- list(
  irf_restriction(variable = 1, shock = 1, horizon = 0, sign = 1),
  irf_restriction(variable = 2, shock = 1, horizon = 0, sign = -1),
  structural_restriction(variable = 1, shock = 1, sign = 1)
)

audit_multi <- restriction_audit(post_b, restrictions = restrictions_multi)

expect_equal(
  nrow(audit_multi),
  3,
  info = "multiple restrictions produce correct number of rows"
)

# Verify each row independently
expect_equal(
  audit_multi$posterior_prob[1],
  manual_sign_prob,
  tolerance = 1e-10,
  info = "multi-restriction row 1 matches manual sign prob"
)
expect_equal(
  audit_multi$posterior_prob[2],
  manual_neg_prob,
  tolerance = 1e-10,
  info = "multi-restriction row 2 matches manual negative sign prob"
)
expect_equal(
  audit_multi$posterior_prob[3],
  manual_struct_prob,
  tolerance = 1e-10,
  info = "multi-restriction row 3 matches manual structural prob"
)

# ===========================================================================
# PosteriorBSVARSIGN fixture (S = 30)
# ===========================================================================
data(optimism, package = "bsvarSIGNs")
set.seed(2026)
sign_irf <- matrix(c(1, rep(NA, 3)), 2, 2)
spec_s   <- suppressMessages(
  bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1, sign_irf = sign_irf)
)
post_s   <- bsvars::estimate(spec_s, S = 30, thin = 1, show_progress = FALSE)
irf_s    <- bsvars::compute_impulse_responses(post_s, horizon = 4, standardise = FALSE)

# ---------------------------------------------------------------------------
# Test 5 -- Default restriction extraction from PosteriorBSVARSIGN
# ---------------------------------------------------------------------------
default_audit <- restriction_audit(post_s, zero_tol = 1e-6)

# Verify it produces rows for both restriction types
expect_true(
  any(default_audit$restriction_type == "irf_sign"),
  info = "default extraction produces irf_sign restriction rows"
)

# For the sign restriction at [1,1] (variable=1, shock=1, horizon=0, sign=1):
manual_default_sign <- mean(irf_s[1, 1, 1, ] > 0)

# Find the matching row: irf_sign type with the correct variable/shock/horizon
sign_rows <- default_audit[default_audit$restriction_type == "irf_sign", ]
# The sign_irf[1,1]=1 means variable=1, shock=1, horizon=0, sign=1
# Match by horizon=0
sign_row_h0 <- sign_rows[sign_rows$horizon == 0, ]
expect_true(
  nrow(sign_row_h0) >= 1,
  info = "default extraction has sign restriction at horizon 0"
)

expect_equal(
  sign_row_h0$posterior_prob[1],
  manual_default_sign,
  tolerance = 1e-10,
  info = "default sign restriction probability matches manual computation"
)

# ---------------------------------------------------------------------------
# Test 6 -- Zero restriction probability from PosteriorBSVARSIGN
# ---------------------------------------------------------------------------
# The NAs in sign_irf do NOT correspond to zero restrictions in bsvarSIGNs.
# Zero restrictions come from explicit 0 values in sign_irf.
# Our sign_irf = matrix(c(1, NA, NA, NA), 2, 2) has no zeros,
# so check whether zero restrictions are present. If the identification
# scheme has no zero restrictions, skip this test gracefully.
zero_rows <- default_audit[default_audit$restriction_type == "irf_zero", ]

if (nrow(zero_rows) > 0) {
  # For zero restrictions: probability = mean(abs(irf) <= zero_tol)
  zr <- zero_rows[1, ]
  # Resolve variable/shock names to indices
  var_names <- dimnames(irf_s)[[1]]
  shock_names <- dimnames(irf_s)[[2]]
  if (is.null(var_names)) var_names <- paste0("variable", seq_len(dim(irf_s)[1]))
  if (is.null(shock_names)) shock_names <- var_names[seq_len(dim(irf_s)[2])]
  var_idx   <- match(zr$variable, var_names)
  shock_idx <- match(zr$shock, shock_names)
  hor_idx   <- as.integer(zr$horizon) + 1L

  manual_zero_prob <- mean(abs(irf_s[var_idx, shock_idx, hor_idx, ]) <= 1e-6)
  expect_equal(
    zr$posterior_prob,
    manual_zero_prob,
    tolerance = 1e-10,
    info = "zero restriction probability matches manual computation"
  )
} else {
  # No zero restrictions: verify the sign_irf setup is as expected
  # (NAs in bsvarSIGNs sign_irf are unrestricted, not zero-restricted)
  expect_true(
    TRUE,
    info = "no zero restrictions in sign_irf (NAs are unrestricted in bsvarSIGNs)"
  )

  # Additional zero restriction test with explicit zero in sign_irf
  set.seed(2026)
  sign_irf_z <- matrix(c(1, 0, NA, NA), 2, 2)
  spec_z <- suppressMessages(
    bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1, sign_irf = sign_irf_z)
  )
  post_z    <- bsvars::estimate(spec_z, S = 30, thin = 1, show_progress = FALSE)
  irf_z     <- bsvars::compute_impulse_responses(post_z, horizon = 4, standardise = FALSE)
  audit_z   <- restriction_audit(post_z, zero_tol = 1e-6)
  zero_rows_z <- audit_z[audit_z$restriction_type == "irf_zero", ]

  expect_true(
    nrow(zero_rows_z) >= 1,
    info = "explicit zero in sign_irf produces irf_zero restriction rows"
  )

  if (nrow(zero_rows_z) > 0) {
    zr_z <- zero_rows_z[1, ]
    # Resolve variable/shock names to array indices using model variable names
    # (the audit function uses infer_model_variable_names to get names from the model)
    model_names_z <- bsvarPost:::infer_model_variable_names(post_z, n = dim(irf_z)[1])
    if (is.null(model_names_z)) model_names_z <- paste0("variable", seq_len(dim(irf_z)[1]))
    var_idx_z   <- match(zr_z$variable, model_names_z)
    shock_idx_z <- match(zr_z$shock, model_names_z)
    hor_idx_z   <- as.integer(zr_z$horizon) + 1L

    manual_zero_prob_z <- mean(abs(irf_z[var_idx_z, shock_idx_z, hor_idx_z, ]) <= 1e-6)
    expect_equal(
      zr_z$posterior_prob,
      manual_zero_prob_z,
      tolerance = 1e-10,
      info = "explicit zero restriction probability matches manual computation"
    )
  }
}
