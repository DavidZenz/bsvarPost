# Test validation helpers and .default S3 methods
# Phase 2: Input Validation Foundation
# Pattern: expect_error(code, pattern, info = "description")

library(tinytest)

# ── Section 1: validate_horizon() ──────────────────────────────────────────

# Valid inputs
expect_equal(
  bsvarPost:::validate_horizon(5), 5L,
  info = "validate_horizon: integer input returns integer"
)
expect_equal(
  bsvarPost:::validate_horizon(10.0), 10L,
  info = "validate_horizon: numeric coerced to integer"
)
expect_equal(
  bsvarPost:::validate_horizon(0, allow_zero = TRUE), 0L,
  info = "validate_horizon: zero allowed when allow_zero=TRUE"
)
expect_equal(
  bsvarPost:::validate_horizon(1, allow_zero = FALSE), 1L,
  info = "validate_horizon: positive value accepted when allow_zero=FALSE"
)
expect_equal(
  bsvarPost:::validate_horizon(100), 100L,
  info = "validate_horizon: large horizon accepted"
)

# Invalid inputs
expect_error(
  bsvarPost:::validate_horizon(-1),
  "non-negative",
  info = "validate_horizon: negative rejected"
)
expect_error(
  bsvarPost:::validate_horizon(-5),
  "non-negative",
  info = "validate_horizon: negative value rejected"
)
expect_error(
  bsvarPost:::validate_horizon(2.5),
  "integer",
  info = "validate_horizon: non-integer rejected"
)
expect_error(
  bsvarPost:::validate_horizon(1.9),
  "integer",
  info = "validate_horizon: non-integer 1.9 rejected"
)
expect_error(
  bsvarPost:::validate_horizon(NULL),
  "cannot be NULL",
  info = "validate_horizon: NULL rejected"
)
expect_error(
  bsvarPost:::validate_horizon(NA),
  "single numeric",
  info = "validate_horizon: bare NA rejected (logical, not numeric)"
)
expect_error(
  bsvarPost:::validate_horizon(NA_real_),
  "non-missing",
  info = "validate_horizon: NA_real_ rejected"
)
expect_error(
  bsvarPost:::validate_horizon(Inf),
  "finite",
  info = "validate_horizon: Inf rejected"
)
expect_error(
  bsvarPost:::validate_horizon(-Inf),
  "finite",
  info = "validate_horizon: -Inf rejected"
)
expect_error(
  bsvarPost:::validate_horizon(c(1, 2)),
  "single numeric",
  info = "validate_horizon: vector rejected"
)
expect_error(
  bsvarPost:::validate_horizon(c(1, 2, 3)),
  "single numeric",
  info = "validate_horizon: longer vector rejected"
)
expect_error(
  bsvarPost:::validate_horizon("5"),
  "single numeric",
  info = "validate_horizon: string rejected"
)
expect_error(
  bsvarPost:::validate_horizon(TRUE),
  "single numeric",
  info = "validate_horizon: logical TRUE rejected (not numeric type)"
)
expect_error(
  bsvarPost:::validate_horizon(0, allow_zero = FALSE),
  "positive",
  info = "validate_horizon: zero rejected when allow_zero=FALSE"
)

# ── Section 2: validate_probability() ──────────────────────────────────────

# Valid inputs
expect_equal(
  bsvarPost:::validate_probability(0.68), 0.68,
  info = "validate_probability: standard probability accepted"
)
expect_equal(
  bsvarPost:::validate_probability(0.5), 0.5,
  info = "validate_probability: midpoint valid"
)
expect_equal(
  bsvarPost:::validate_probability(0.001), 0.001,
  info = "validate_probability: near-zero valid"
)
expect_equal(
  bsvarPost:::validate_probability(0.999), 0.999,
  info = "validate_probability: near-one valid"
)
expect_equal(
  bsvarPost:::validate_probability(0.0001), 0.0001,
  info = "validate_probability: very small valid"
)
expect_equal(
  bsvarPost:::validate_probability(0.9999), 0.9999,
  info = "validate_probability: very large valid"
)

# Invalid inputs - boundary
expect_error(
  bsvarPost:::validate_probability(0),
  "between 0 and 1",
  info = "validate_probability: zero rejected (exclusive lower bound)"
)
expect_error(
  bsvarPost:::validate_probability(1),
  "between 0 and 1",
  info = "validate_probability: one rejected (exclusive upper bound)"
)
expect_error(
  bsvarPost:::validate_probability(1.5),
  "between 0 and 1",
  info = "validate_probability: >1 rejected"
)
expect_error(
  bsvarPost:::validate_probability(-0.1),
  "between 0 and 1",
  info = "validate_probability: negative rejected"
)
expect_error(
  bsvarPost:::validate_probability(2),
  "between 0 and 1",
  info = "validate_probability: far >1 rejected"
)

# Invalid inputs - type/missing
expect_error(
  bsvarPost:::validate_probability(NULL),
  "cannot be NULL",
  info = "validate_probability: NULL rejected"
)
expect_error(
  bsvarPost:::validate_probability(NA),
  "single numeric",
  info = "validate_probability: bare NA rejected (logical, not numeric)"
)
expect_error(
  bsvarPost:::validate_probability(NA_real_),
  "non-missing",
  info = "validate_probability: NA_real_ rejected"
)
expect_error(
  bsvarPost:::validate_probability(Inf),
  "finite",
  info = "validate_probability: Inf rejected"
)
expect_error(
  bsvarPost:::validate_probability(-Inf),
  "finite",
  info = "validate_probability: -Inf rejected"
)
expect_error(
  bsvarPost:::validate_probability(c(0.5, 0.7)),
  "single numeric",
  info = "validate_probability: vector rejected"
)
expect_error(
  bsvarPost:::validate_probability("0.5"),
  "single numeric",
  info = "validate_probability: string rejected"
)

# ── Section 3: validate_posterior_object() ─────────────────────────────────

expect_error(
  bsvarPost:::validate_posterior_object(list()),
  "posterior model object",
  info = "validate_posterior_object: list rejected"
)
expect_error(
  bsvarPost:::validate_posterior_object(data.frame()),
  "posterior model object",
  info = "validate_posterior_object: data.frame rejected"
)
expect_error(
  bsvarPost:::validate_posterior_object(42),
  "posterior model object",
  info = "validate_posterior_object: numeric rejected"
)
expect_error(
  bsvarPost:::validate_posterior_object("model"),
  "posterior model object",
  info = "validate_posterior_object: string rejected"
)
expect_error(
  bsvarPost:::validate_posterior_object(NULL),
  "posterior model object",
  info = "validate_posterior_object: NULL rejected"
)
expect_error(
  bsvarPost:::validate_posterior_object(matrix(1:4, 2, 2)),
  "posterior model object",
  info = "validate_posterior_object: matrix rejected"
)

# Check error message contains expected classes
tryCatch(
  bsvarPost:::validate_posterior_object(list()),
  error = function(e) {
    expect_true(
      grepl("PosteriorBSVAR", e$message),
      info = "validate_posterior_object: error mentions PosteriorBSVAR"
    )
    expect_true(
      grepl("PosteriorBSVARSIGN", e$message),
      info = "validate_posterior_object: error mentions PosteriorBSVARSIGN"
    )
    expect_true(
      grepl("list", e$message),
      info = "validate_posterior_object: error mentions received class"
    )
  }
)

# ── Section 4: tidy_* .default methods ─────────────────────────────────────

expect_error(
  tidy_irf(list()),
  "posterior model object",
  info = "tidy_irf.default: list rejected"
)
expect_error(
  tidy_irf(data.frame(x = 1)),
  "posterior model object",
  info = "tidy_irf.default: data.frame rejected"
)
expect_error(
  tidy_irf(42),
  "posterior model object",
  info = "tidy_irf.default: numeric rejected"
)

expect_error(
  tidy_cdm(list()),
  "posterior model object",
  info = "tidy_cdm.default: list rejected"
)
expect_error(
  tidy_cdm(42),
  "posterior model object",
  info = "tidy_cdm.default: numeric rejected"
)

expect_error(
  tidy_fevd(list()),
  "posterior model object",
  info = "tidy_fevd.default: list rejected"
)

expect_error(
  tidy_shocks(data.frame()),
  "posterior model object",
  info = "tidy_shocks.default: data.frame rejected"
)

expect_error(
  tidy_hd(list()),
  "posterior model object",
  info = "tidy_hd.default: list rejected"
)

expect_error(
  tidy_forecast(42),
  "posterior model object",
  info = "tidy_forecast.default: numeric rejected"
)

expect_error(
  tidy_hd_event(list()),
  "posterior model object",
  info = "tidy_hd_event.default: list rejected"
)

# Verify error mentions received class
tryCatch(
  tidy_irf(data.frame(x = 1)),
  error = function(e) {
    expect_true(
      grepl("data.frame", e$message),
      info = "tidy_irf.default: error mentions data.frame class"
    )
  }
)

# ── Section 5: hypothesis_* .default methods ───────────────────────────────

expect_error(
  hypothesis_irf(list()),
  "posterior model object",
  info = "hypothesis_irf.default: list rejected"
)
expect_error(
  hypothesis_irf(data.frame()),
  "posterior model object",
  info = "hypothesis_irf.default: data.frame rejected"
)
expect_error(
  hypothesis_cdm(data.frame()),
  "posterior model object",
  info = "hypothesis_cdm.default: data.frame rejected"
)
expect_error(
  hypothesis_cdm(42),
  "posterior model object",
  info = "hypothesis_cdm.default: numeric rejected"
)

# ── Section 6: representative_* .default methods ──────────────────────────

expect_error(
  representative_irf(list()),
  "posterior model object",
  info = "representative_irf.default: list rejected"
)
expect_error(
  representative_irf(data.frame()),
  "posterior model object",
  info = "representative_irf.default: data.frame rejected"
)
expect_error(
  representative_cdm(42),
  "posterior model object",
  info = "representative_cdm.default: numeric rejected"
)
expect_error(
  representative_cdm(list()),
  "posterior model object",
  info = "representative_cdm.default: list rejected"
)

# ── Section 7: response summary .default methods ──────────────────────────

expect_error(
  peak_response(list()),
  "PosteriorIR or PosteriorCDM",
  info = "peak_response.default: list rejected"
)
expect_error(
  peak_response(data.frame()),
  "PosteriorIR or PosteriorCDM",
  info = "peak_response.default: data.frame rejected"
)

expect_error(
  duration_response(list()),
  "PosteriorIR or PosteriorCDM",
  info = "duration_response.default: list rejected"
)
expect_error(
  duration_response(42),
  "PosteriorIR or PosteriorCDM",
  info = "duration_response.default: numeric rejected"
)

expect_error(
  half_life_response(42),
  "PosteriorIR or PosteriorCDM",
  info = "half_life_response.default: numeric rejected"
)
expect_error(
  half_life_response(list()),
  "PosteriorIR or PosteriorCDM",
  info = "half_life_response.default: list rejected"
)

expect_error(
  time_to_threshold(list()),
  "PosteriorIR or PosteriorCDM",
  info = "time_to_threshold.default: list rejected"
)
expect_error(
  time_to_threshold(data.frame()),
  "PosteriorIR or PosteriorCDM",
  info = "time_to_threshold.default: data.frame rejected"
)

# ── Section 8: cdm .default method ────────────────────────────────────────

expect_error(
  cdm(list()),
  "posterior model object",
  info = "cdm.default: list rejected"
)
expect_error(
  cdm(data.frame()),
  "posterior model object",
  info = "cdm.default: data.frame rejected"
)
expect_error(
  cdm(42),
  "posterior model object",
  info = "cdm.default: numeric rejected"
)

# ── Section 9: joint inference .default methods ───────────────────────────

expect_error(
  simultaneous_irf(list()),
  "posterior model object",
  info = "simultaneous_irf.default: list rejected"
)
expect_error(
  simultaneous_irf(data.frame()),
  "posterior model object",
  info = "simultaneous_irf.default: data.frame rejected"
)

expect_error(
  simultaneous_cdm(list()),
  "posterior model object",
  info = "simultaneous_cdm.default: list rejected"
)

expect_error(
  joint_hypothesis_irf(list()),
  "posterior model object",
  info = "joint_hypothesis_irf.default: list rejected"
)
expect_error(
  joint_hypothesis_irf(42),
  "posterior model object",
  info = "joint_hypothesis_irf.default: numeric rejected"
)

expect_error(
  joint_hypothesis_cdm(list()),
  "posterior model object",
  info = "joint_hypothesis_cdm.default: list rejected"
)
expect_error(
  joint_hypothesis_cdm(42),
  "posterior model object",
  info = "joint_hypothesis_cdm.default: numeric rejected"
)
