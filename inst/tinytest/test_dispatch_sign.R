Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# -----------------------------------------------------------------------
# test_dispatch_sign.R
# S3 dispatch coverage for PosteriorBSVARSIGN across all key generic families.
# -----------------------------------------------------------------------

data(optimism, package = "bsvarSIGNs")
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
set.seed(1)
spec_sign <- bsvarSIGNs::specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
post_sign <- suppressMessages(
  bsvars::estimate(spec_sign, S = 5, thin = 1, show_progress = FALSE)
)

# Second posterior for compare_* functions
set.seed(2)
post_sign2 <- suppressMessages(
  bsvars::estimate(spec_sign, S = 5, thin = 1, show_progress = FALSE)
)

# -----------------------------------------------------------------------
# 1. tidy_irf
# -----------------------------------------------------------------------
tidy_irf_tbl <- tidy_irf(post_sign, horizon = 2)
expect_true(inherits(tidy_irf_tbl, "bsvar_post_tbl"),
  info = "tidy_irf/PosteriorBSVARSIGN: returns bsvar_post_tbl")
expect_true(nrow(tidy_irf_tbl) > 0,
  info = "tidy_irf/PosteriorBSVARSIGN: nrow > 0")

# -----------------------------------------------------------------------
# 2. tidy_cdm
# -----------------------------------------------------------------------
tidy_cdm_tbl <- tidy_cdm(post_sign, horizon = 2)
expect_true(inherits(tidy_cdm_tbl, "bsvar_post_tbl"),
  info = "tidy_cdm/PosteriorBSVARSIGN: returns bsvar_post_tbl")
expect_true(nrow(tidy_cdm_tbl) > 0,
  info = "tidy_cdm/PosteriorBSVARSIGN: nrow > 0")

# -----------------------------------------------------------------------
# 3. tidy_fevd
# -----------------------------------------------------------------------
tidy_fevd_tbl <- tidy_fevd(post_sign, horizon = 2)
expect_true(inherits(tidy_fevd_tbl, "bsvar_post_tbl"),
  info = "tidy_fevd/PosteriorBSVARSIGN: returns bsvar_post_tbl")
expect_true(nrow(tidy_fevd_tbl) > 0,
  info = "tidy_fevd/PosteriorBSVARSIGN: nrow > 0")

# -----------------------------------------------------------------------
# 4. hypothesis_irf
# -----------------------------------------------------------------------
hyp_irf <- hypothesis_irf(post_sign, horizon = 2, variable = 1, shock = 1, relation = ">")
expect_true(is.data.frame(hyp_irf),
  info = "hypothesis_irf/PosteriorBSVARSIGN: returns data.frame")
expect_true("posterior_prob" %in% names(hyp_irf),
  info = "hypothesis_irf/PosteriorBSVARSIGN: has posterior_prob")
expect_true(hyp_irf$posterior_prob >= 0 && hyp_irf$posterior_prob <= 1,
  info = "hypothesis_irf/PosteriorBSVARSIGN: posterior_prob in [0, 1]")

# -----------------------------------------------------------------------
# 5. representative_irf
# -----------------------------------------------------------------------
rep_irf <- representative_irf(post_sign, horizon = 2)
expect_true(inherits(rep_irf, "RepresentativeIR"),
  info = "representative_irf/PosteriorBSVARSIGN: returns RepresentativeIR")
expect_true(is.integer(rep_irf$draw_index),
  info = "representative_irf/PosteriorBSVARSIGN: draw_index is integer")
expect_true("method" %in% names(rep_irf),
  info = "representative_irf/PosteriorBSVARSIGN: has method")

# -----------------------------------------------------------------------
# 6. compare_irf
# -----------------------------------------------------------------------
cmp_irf_sign <- compare_irf(base = post_sign, alt = post_sign2, horizon = 2)
expect_true(inherits(cmp_irf_sign, "bsvar_post_tbl"),
  info = "compare_irf/PosteriorBSVARSIGN: returns bsvar_post_tbl")
expect_equal(sort(unique(cmp_irf_sign$model)), c("alt", "base"),
  info = "compare_irf/PosteriorBSVARSIGN: model values are base and alt")

# -----------------------------------------------------------------------
# 7. compare_restrictions (PosteriorBSVARSIGN-specific)
# -----------------------------------------------------------------------
cmp_restr <- compare_restrictions(base = post_sign, alt = post_sign2)
expect_true(inherits(cmp_restr, "bsvar_post_tbl"),
  info = "compare_restrictions/PosteriorBSVARSIGN: returns bsvar_post_tbl")
expect_true(nrow(cmp_restr) > 0,
  info = "compare_restrictions/PosteriorBSVARSIGN: nrow > 0")
expect_true("model" %in% names(cmp_restr),
  info = "compare_restrictions/PosteriorBSVARSIGN: has model column")
expect_equal(sort(unique(cmp_restr$model)), c("alt", "base"),
  info = "compare_restrictions/PosteriorBSVARSIGN: model values are base and alt")
expect_true(isTRUE(attr(cmp_restr, "compare")),
  info = "compare_restrictions/PosteriorBSVARSIGN: compare attribute is TRUE")
expect_true("posterior_prob" %in% names(cmp_restr),
  info = "compare_restrictions/PosteriorBSVARSIGN: has posterior_prob column")

# -----------------------------------------------------------------------
# 8. acceptance_diagnostics
# -----------------------------------------------------------------------
acc_diag <- acceptance_diagnostics(post_sign)
expect_true(inherits(acc_diag, "bsvar_post_tbl"),
  info = "acceptance_diagnostics/PosteriorBSVARSIGN: returns bsvar_post_tbl")
expect_true(all(c("metric", "value", "flag", "message") %in% names(acc_diag)),
  info = "acceptance_diagnostics/PosteriorBSVARSIGN: has metric/value/flag/message columns")
expect_true("posterior_draws" %in% acc_diag$metric,
  info = "acceptance_diagnostics/PosteriorBSVARSIGN: contains posterior_draws metric")

# -----------------------------------------------------------------------
# 9. restriction_audit
# -----------------------------------------------------------------------
rest_audit <- restriction_audit(post_sign, zero_tol = 1e-6)
expect_true(inherits(rest_audit, "bsvar_post_tbl"),
  info = "restriction_audit/PosteriorBSVARSIGN: returns bsvar_post_tbl")
expect_true(nrow(rest_audit) > 0,
  info = "restriction_audit/PosteriorBSVARSIGN: nrow > 0")
expect_true("posterior_prob" %in% names(rest_audit),
  info = "restriction_audit/PosteriorBSVARSIGN: has posterior_prob")
expect_true(all(rest_audit$posterior_prob >= 0 & rest_audit$posterior_prob <= 1),
  info = "restriction_audit/PosteriorBSVARSIGN: all posterior_probs in [0, 1]")

# -----------------------------------------------------------------------
# 10. shock_ranking
# -----------------------------------------------------------------------
# shock_ranking uses tidy_hd time labels (not integer horizons)
times_sign <- unique(as.character(tidy_hd(post_sign, draws = TRUE)$time))
sr <- shock_ranking(post_sign, start = times_sign[1], end = times_sign[1])
expect_true(inherits(sr, "bsvar_post_tbl"),
  info = "shock_ranking/PosteriorBSVARSIGN: returns bsvar_post_tbl")
expect_true(nrow(sr) > 0,
  info = "shock_ranking/PosteriorBSVARSIGN: nrow > 0")
expect_true(all(c("ranking", "rank_score", "rank") %in% names(sr)),
  info = "shock_ranking/PosteriorBSVARSIGN: has ranking/rank_score/rank columns")
