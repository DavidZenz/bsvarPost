# Test behavioral edge cases with real posterior objects
# Phase 5: Test Coverage Expansion - Gap 2 closure
# Covers: 1-variable posterior, S=1 single draw, empty/invalid variable selections

Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# ── Section 1: Minimal 2-variable posterior model ─────────────────────────────
# Note: bsvars::specify_bsvar requires at least 2 variables; 2-variable is the
# smallest valid model. We test that a small (minimal) model flows through the
# full pipeline without crashes.

data(us_fiscal_lsuw, package = "bsvars")
y2 <- us_fiscal_lsuw[, 1:2, drop = FALSE]  # Minimal 2-variable model

set.seed(1)
spec_1v <- bsvars::specify_bsvar$new(y2, p = 1)
post_1v  <- bsvars::estimate(spec_1v, S = 5, thin = 1, show_progress = FALSE)

irf_1v <- tidy_irf(post_1v, horizon = 2)

expect_true(
  inherits(irf_1v, "bsvar_post_tbl"),
  info = "minimal 2-variable model: tidy_irf returns bsvar_post_tbl"
)

expect_true(
  nrow(irf_1v) > 0,
  info = "minimal 2-variable model: tidy_irf returns non-empty result"
)

expect_equal(
  length(unique(irf_1v$variable)), 2L,
  info = "minimal 2-variable model: tidy_irf result has exactly 2 unique variables"
)

expect_equal(
  length(unique(irf_1v$shock)), 2L,
  info = "minimal 2-variable model: tidy_irf result has exactly 2 unique shocks"
)

fevd_1v <- tidy_fevd(post_1v, horizon = 2)

expect_true(
  inherits(fevd_1v, "bsvar_post_tbl"),
  info = "minimal 2-variable model: tidy_fevd returns bsvar_post_tbl"
)

expect_true(
  nrow(fevd_1v) > 0,
  info = "minimal 2-variable model: tidy_fevd returns non-empty result"
)

# ── Section 2: Minimum-draw posterior (S=2) ───────────────────────────────────
# Note: bsvars::estimate requires S >= 2; S=1 is rejected upstream.
# S=2 is the minimum valid value and exercises the degenerate-quantile boundary.

set.seed(1)
spec_s1 <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_s1  <- bsvars::estimate(spec_s1, S = 2, thin = 1, show_progress = FALSE)

irf_s1 <- tidy_irf(post_s1, horizon = 2)

expect_true(
  inherits(irf_s1, "bsvar_post_tbl"),
  info = "S=2 minimum-draw model: tidy_irf returns bsvar_post_tbl"
)

expect_true(
  nrow(irf_s1) > 0,
  info = "S=2 minimum-draw model: tidy_irf returns non-empty result"
)

expect_true(
  all(irf_s1$lower <= irf_s1$median),
  info = "S=2 minimum-draw model: lower <= median for all rows"
)

expect_true(
  all(irf_s1$median <= irf_s1$upper),
  info = "S=2 minimum-draw model: median <= upper for all rows"
)

# ── Section 3: Empty/invalid variable selections ──────────────────────────────

# Empty character vector — returns integer(0) without error (acceptable behavior)
result_empty <- bsvarPost:::resolve_selection(character(0), c("a", "b"))
expect_true(
  length(result_empty) == 0L,
  info = "resolve_selection: empty character(0) returns integer(0) (length 0)"
)

# Unknown label produces informative error
expect_error(
  bsvarPost:::resolve_selection("nonexistent", c("a", "b")),
  "Unknown selection",
  info = "resolve_selection: unknown label produces informative error"
)

# Out-of-range integer produces informative error
expect_error(
  bsvarPost:::resolve_selection(99L, c("a", "b")),
  "out of bounds",
  info = "resolve_selection: out-of-range integer produces informative error"
)
