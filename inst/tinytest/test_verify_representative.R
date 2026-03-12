Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# ===========================================================================
# PosteriorBSVAR fixture (S = 30)
# ===========================================================================
data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b  <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b  <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)
irf_raw <- bsvars::compute_impulse_responses(post_b, horizon = 8)

# ---------------------------------------------------------------------------
# Test 1 -- median_target_irf: draw_index is which.min of L2 distances
# ---------------------------------------------------------------------------
# Manual computation mirrors compute_representative_draw with default params
mat <- matrix(as.numeric(irf_raw), nrow = prod(dim(irf_raw)[1:3]), ncol = dim(irf_raw)[4])
target <- apply(mat, 1, stats::median)
distances <- colSums((mat - target)^2)
expected_idx <- which.min(distances)

rep_irf <- median_target_irf(post_b, horizon = 8)

expect_equal(
  rep_irf$draw_index,
  expected_idx,
  info = "median_target_irf draw_index matches manual which.min(L2 distances)"
)

# ---------------------------------------------------------------------------
# Test 2 -- median_target_irf: selected draw values match raw array
# ---------------------------------------------------------------------------
# The representative_draw should be irf_raw[,,,expected_idx]
manual_draw <- irf_raw[, , , expected_idx, drop = FALSE]

expect_equal(
  as.numeric(rep_irf$representative_draw),
  as.numeric(manual_draw),
  tolerance = 1e-10,
  info = "median_target_irf representative_draw values match raw IRF array at selected index"
)

# ---------------------------------------------------------------------------
# Test 3 -- median_target_irf: score equals negative distance
# ---------------------------------------------------------------------------
expect_equal(
  rep_irf$score,
  -distances[expected_idx],
  tolerance = 1e-10,
  info = "median_target_irf score equals negative of minimum L2 distance"
)

# ---------------------------------------------------------------------------
# Test 4 -- median_target_cdm: draw_index for CDM variant
# ---------------------------------------------------------------------------
cdm_draws <- bsvarPost:::get_cdm_draws(post_b, horizon = 8)
mat_cdm   <- matrix(as.numeric(cdm_draws), nrow = prod(dim(cdm_draws)[1:3]), ncol = dim(cdm_draws)[4])
target_cdm <- apply(mat_cdm, 1, stats::median)
dist_cdm   <- colSums((mat_cdm - target_cdm)^2)
expected_cdm_idx <- which.min(dist_cdm)

rep_cdm <- median_target_cdm(post_b, horizon = 8)

expect_equal(
  rep_cdm$draw_index,
  expected_cdm_idx,
  info = "median_target_cdm draw_index matches manual which.min(L2 distances)"
)

# ---------------------------------------------------------------------------
# Test 5 -- median_target_cdm: score equals negative distance
# ---------------------------------------------------------------------------
expect_equal(
  rep_cdm$score,
  -dist_cdm[expected_cdm_idx],
  tolerance = 1e-10,
  info = "median_target_cdm score equals negative of minimum L2 distance"
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

# ---------------------------------------------------------------------------
# Test 6 -- most_likely_admissible_irf: highest kernel score
# ---------------------------------------------------------------------------
scores <- bsvarPost:::compute_posterior_kernel(post_s)
rep_sign <- most_likely_admissible_irf(post_s, horizon = 8)

expect_equal(
  rep_sign$score,
  max(scores),
  tolerance = 1e-10,
  info = "most_likely_admissible_irf score equals max kernel score"
)

expect_true(
  rep_sign$draw_index %in% which(scores == max(scores)),
  info = "most_likely_admissible_irf draw_index is among highest-score draws"
)

# ---------------------------------------------------------------------------
# Test 7 -- most_likely_admissible tie-breaking: L2 distance among tied draws
# ---------------------------------------------------------------------------
candidates <- which(scores == max(scores))
if (length(candidates) > 1L) {
  # Tie-breaking: among tied draws, select the one closest to median target
  irf_sign <- bsvarPost:::get_irf_draws(post_s, horizon = 8)
  mat_sign <- matrix(as.numeric(irf_sign), nrow = prod(dim(irf_sign)[1:3]), ncol = dim(irf_sign)[4])
  target_sign <- apply(mat_sign, 1, stats::median)
  dist_sign <- colSums((mat_sign - target_sign)^2)
  expected_tie_idx <- candidates[which.min(dist_sign[candidates])]

  expect_equal(
    rep_sign$draw_index,
    expected_tie_idx,
    info = "most_likely_admissible tie-breaking selects minimum L2 distance among tied draws"
  )
} else {
  expect_equal(
    rep_sign$draw_index,
    candidates[1],
    info = "most_likely_admissible with unique max score selects that draw"
  )
}

# ---------------------------------------------------------------------------
# Test 8 -- Class and summary structure
# ---------------------------------------------------------------------------
expect_true(
  inherits(rep_irf, "RepresentativeIR"),
  info = "median_target_irf returns RepresentativeIR class"
)
expect_true(
  inherits(rep_irf, "RepresentativeResponse"),
  info = "median_target_irf inherits RepresentativeResponse"
)
expect_true(
  inherits(rep_cdm, "RepresentativeCDM"),
  info = "median_target_cdm returns RepresentativeCDM class"
)

summ <- summary(rep_irf)
expect_true(
  inherits(summ, "bsvar_post_tbl"),
  info = "summary of RepresentativeIR returns bsvar_post_tbl"
)
expect_true(
  "draw_index" %in% names(summ),
  info = "summary includes draw_index column"
)
