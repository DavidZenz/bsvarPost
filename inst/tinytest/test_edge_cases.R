# Test edge case handling across function families
# Phase 2: Input Validation Foundation
# Tests requirement R2: edge cases produce informative errors or work correctly

library(tinytest)

# ── Section 1: Horizon edge cases ─────────────────────────────────────────

# horizon = 0 should be accepted (impact only)
expect_equal(
  bsvarPost:::validate_horizon(0, allow_zero = TRUE), 0L,
  info = "Edge case: horizon = 0 accepted when allow_zero = TRUE"
)

# horizon = 0 rejected when not allowed
expect_error(
  bsvarPost:::validate_horizon(0, allow_zero = FALSE),
  "positive",
  info = "Edge case: horizon = 0 rejected when allow_zero = FALSE"
)

# Negative horizon always rejected
expect_error(
  bsvarPost:::validate_horizon(-1),
  "non-negative",
  info = "Edge case: negative horizon -1 rejected"
)
expect_error(
  bsvarPost:::validate_horizon(-100),
  "non-negative",
  info = "Edge case: negative horizon -100 rejected"
)

# Non-integer horizon rejected
expect_error(
  bsvarPost:::validate_horizon(1.5),
  "integer",
  info = "Edge case: non-integer horizon 1.5 rejected"
)
expect_error(
  bsvarPost:::validate_horizon(0.5),
  "integer",
  info = "Edge case: non-integer horizon 0.5 rejected"
)
expect_error(
  bsvarPost:::validate_horizon(10.1),
  "integer",
  info = "Edge case: non-integer horizon 10.1 rejected"
)

# ── Section 2: Probability edge cases ─────────────────────────────────────

# Exclusive bounds
expect_error(
  bsvarPost:::validate_probability(0),
  "between 0 and 1",
  info = "Edge case: probability = 0 rejected (exclusive bound)"
)
expect_error(
  bsvarPost:::validate_probability(1),
  "between 0 and 1",
  info = "Edge case: probability = 1 rejected (exclusive bound)"
)

# Values just outside bounds
expect_error(
  bsvarPost:::validate_probability(1.001),
  "between 0 and 1",
  info = "Edge case: probability just > 1 rejected"
)
expect_error(
  bsvarPost:::validate_probability(-0.001),
  "between 0 and 1",
  info = "Edge case: negative probability rejected"
)

# Values just inside bounds are accepted
expect_equal(
  bsvarPost:::validate_probability(0.0001), 0.0001,
  info = "Edge case: very small probability accepted"
)
expect_equal(
  bsvarPost:::validate_probability(0.9999), 0.9999,
  info = "Edge case: very large probability accepted"
)

# ── Section 3: NULL handling ──────────────────────────────────────────────

expect_error(
  bsvarPost:::validate_horizon(NULL),
  "cannot be NULL",
  info = "Edge case: NULL horizon rejected"
)
expect_error(
  bsvarPost:::validate_probability(NULL),
  "cannot be NULL",
  info = "Edge case: NULL probability rejected"
)
# NULL posterior object
expect_error(
  bsvarPost:::validate_posterior_object(NULL),
  "posterior model object",
  info = "Edge case: NULL posterior object rejected"
)

# ── Section 4: NA/Inf handling ────────────────────────────────────────────

expect_error(
  bsvarPost:::validate_horizon(NA),
  "single numeric",
  info = "Edge case: bare NA horizon rejected (logical, not numeric)"
)
expect_error(
  bsvarPost:::validate_horizon(NA_real_),
  "non-missing",
  info = "Edge case: NA_real_ horizon rejected"
)
expect_error(
  bsvarPost:::validate_horizon(Inf),
  "finite",
  info = "Edge case: Inf horizon rejected"
)
expect_error(
  bsvarPost:::validate_horizon(-Inf),
  "finite",
  info = "Edge case: -Inf horizon rejected"
)

expect_error(
  bsvarPost:::validate_probability(NA),
  "single numeric",
  info = "Edge case: bare NA probability rejected (logical, not numeric)"
)
expect_error(
  bsvarPost:::validate_probability(Inf),
  "finite",
  info = "Edge case: Inf probability rejected"
)
expect_error(
  bsvarPost:::validate_probability(-Inf),
  "finite",
  info = "Edge case: -Inf probability rejected"
)

# ── Section 5: Vector inputs (should be scalar) ──────────────────────────

expect_error(
  bsvarPost:::validate_horizon(c(1, 2, 3)),
  "single numeric",
  info = "Edge case: vector horizon rejected"
)
expect_error(
  bsvarPost:::validate_horizon(integer(0)),
  "single numeric",
  info = "Edge case: empty vector horizon rejected"
)
expect_error(
  bsvarPost:::validate_probability(c(0.5, 0.7)),
  "single numeric",
  info = "Edge case: vector probability rejected"
)
expect_error(
  bsvarPost:::validate_probability(numeric(0)),
  "single numeric",
  info = "Edge case: empty vector probability rejected"
)

# ── Section 6: Type coercion edge cases ───────────────────────────────────

expect_error(
  bsvarPost:::validate_horizon("10"),
  "single numeric",
  info = "Edge case: string horizon rejected (no silent coercion)"
)
expect_error(
  bsvarPost:::validate_probability("0.5"),
  "single numeric",
  info = "Edge case: string probability rejected (no silent coercion)"
)
expect_error(
  bsvarPost:::validate_horizon(list(5)),
  "single numeric",
  info = "Edge case: list horizon rejected"
)
expect_error(
  bsvarPost:::validate_probability(list(0.5)),
  "single numeric",
  info = "Edge case: list probability rejected"
)

# ── Section 7: Wrong object types for .default methods ────────────────────

# tidy family
expect_error(
  tidy_irf(data.frame(x = 1, y = 2)),
  "posterior model object",
  info = "Edge case: data.frame rejected by tidy_irf"
)
expect_error(
  tidy_cdm(list(a = 1)),
  "posterior model object",
  info = "Edge case: list rejected by tidy_cdm"
)

# hypothesis family
expect_error(
  hypothesis_irf(list(a = 1, b = 2)),
  "posterior model object",
  info = "Edge case: list rejected by hypothesis_irf"
)
expect_error(
  hypothesis_cdm(42),
  "posterior model object",
  info = "Edge case: numeric rejected by hypothesis_cdm"
)

# representative family
expect_error(
  representative_cdm(matrix(1:10, nrow = 2)),
  "posterior model object",
  info = "Edge case: matrix rejected by representative_cdm"
)
expect_error(
  representative_irf(c(1, 2, 3)),
  "posterior model object",
  info = "Edge case: vector rejected by representative_irf"
)

# response summary family
expect_error(
  peak_response(c(1, 2, 3, 4, 5)),
  "PosteriorIR or PosteriorCDM",
  info = "Edge case: vector rejected by peak_response"
)
expect_error(
  duration_response(TRUE),
  "PosteriorIR or PosteriorCDM",
  info = "Edge case: logical rejected by duration_response"
)
expect_error(
  half_life_response(matrix(1:4, 2, 2)),
  "PosteriorIR or PosteriorCDM",
  info = "Edge case: matrix rejected by half_life_response"
)
expect_error(
  time_to_threshold("test"),
  "PosteriorIR or PosteriorCDM",
  info = "Edge case: string rejected by time_to_threshold"
)

# cdm
expect_error(
  cdm(c(1, 2, 3)),
  "posterior model object",
  info = "Edge case: vector rejected by cdm"
)

# joint inference family
expect_error(
  simultaneous_irf(list(a = 1)),
  "posterior model object",
  info = "Edge case: list rejected by simultaneous_irf"
)
expect_error(
  joint_hypothesis_irf(data.frame()),
  "posterior model object",
  info = "Edge case: data.frame rejected by joint_hypothesis_irf"
)
expect_error(
  joint_hypothesis_cdm(TRUE),
  "posterior model object",
  info = "Edge case: logical rejected by joint_hypothesis_cdm"
)

# ── Section 8: Boundary value testing ─────────────────────────────────────

# Large horizon values
expect_equal(
  bsvarPost:::validate_horizon(1000), 1000L,
  info = "Edge case: large horizon 1000 accepted"
)
expect_equal(
  bsvarPost:::validate_horizon(1), 1L,
  info = "Edge case: horizon = 1 accepted"
)

# Integer coercion preserved
expect_true(
  is.integer(bsvarPost:::validate_horizon(5)),
  info = "Edge case: validate_horizon returns integer type"
)
expect_true(
  is.integer(bsvarPost:::validate_horizon(0)),
  info = "Edge case: validate_horizon(0) returns integer type"
)

# Probability exact return
expect_identical(
  bsvarPost:::validate_probability(0.68), 0.68,
  info = "Edge case: validate_probability returns exact value"
)

# ── Section 9: Custom arg_name in error messages ──────────────────────────

expect_error(
  bsvarPost:::validate_horizon(-1, arg_name = "forecast_horizon"),
  "forecast_horizon",
  info = "Edge case: custom arg_name appears in horizon error"
)
expect_error(
  bsvarPost:::validate_probability(2, arg_name = "ci_level"),
  "ci_level",
  info = "Edge case: custom arg_name appears in probability error"
)
expect_error(
  bsvarPost:::validate_posterior_object(list(), arg_name = "model"),
  "model",
  info = "Edge case: custom arg_name appears in posterior object error"
)

# ── Section 10: Error message class verification ──────────────────────────
# Verify errors have no call (call. = FALSE pattern)

tryCatch(
  tidy_irf(42),
  error = function(e) {
    expect_null(
      e$call,
      info = "Edge case: .default method error has no call"
    )
  }
)

tryCatch(
  bsvarPost:::validate_horizon(-1),
  error = function(e) {
    expect_null(
      e$call,
      info = "Edge case: validate_horizon error has no call"
    )
  }
)
