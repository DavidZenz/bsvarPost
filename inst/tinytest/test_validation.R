library(tinytest)

error_message <- function(expr) {
  tryCatch({
    force(expr)
    NA_character_
  }, error = conditionMessage)
}

# Scalar validators: one accepted interior value, one boundary, and one case for
# each distinct rejection branch. Repeating nearby values does not add coverage.
expect_identical(bsvarPost:::validate_horizon(5), 5L)
expect_identical(bsvarPost:::validate_horizon(0, allow_zero = TRUE), 0L)

horizon_inputs <- list(-1, 2.5, NULL, NA_real_, Inf, c(1, 2), "5", 0)
horizon_patterns <- c(
  "non-negative", "integer", "cannot be NULL", "non-missing", "finite",
  "single numeric", "single numeric", "positive"
)
horizon_messages <- vapply(seq_along(horizon_inputs), function(i) {
  error_message(bsvarPost:::validate_horizon(
    horizon_inputs[[i]],
    allow_zero = i != length(horizon_inputs)
  ))
}, character(1))
expect_true(all(mapply(grepl, horizon_patterns, horizon_messages, fixed = TRUE)))

expect_identical(bsvarPost:::validate_probability(0.68), 0.68)
probability_inputs <- list(0, 1, -0.1, 1.1, NULL, NA_real_, Inf, c(0.5, 0.7), "0.5")
probability_patterns <- c(
  rep("between 0 and 1", 4), "cannot be NULL", "non-missing", "finite",
  "single numeric", "single numeric"
)
probability_messages <- vapply(probability_inputs, function(x) {
  error_message(bsvarPost:::validate_probability(x))
}, character(1))
expect_true(all(mapply(grepl, probability_patterns, probability_messages, fixed = TRUE)))

# Posterior validation should identify both the contract and the received type,
# and package errors intentionally omit noisy calls.
posterior_error <- tryCatch(
  bsvarPost:::validate_posterior_object(list()),
  error = identity
)
expect_true(
  inherits(posterior_error, "error") &&
    grepl("PosteriorBSVAR", conditionMessage(posterior_error), fixed = TRUE) &&
    grepl("PosteriorBSVARSIGN", conditionMessage(posterior_error), fixed = TRUE) &&
    grepl("list", conditionMessage(posterior_error), fixed = TRUE) &&
    is.null(posterior_error$call)
)

# Exercise every .default route once. Their common validator is tested above;
# this matrix protects registration and the user-facing class contract.
posterior_defaults <- list(
  tidy_irf = function() tidy_irf(list()),
  tidy_cdm = function() tidy_cdm(list()),
  tidy_fevd = function() tidy_fevd(list()),
  tidy_shocks = function() tidy_shocks(list()),
  tidy_hd = function() tidy_hd(list()),
  tidy_forecast = function() tidy_forecast(list()),
  tidy_hd_event = function() tidy_hd_event(list()),
  hypothesis_irf = function() hypothesis_irf(list()),
  hypothesis_cdm = function() hypothesis_cdm(list()),
  representative_irf = function() representative_irf(list()),
  representative_cdm = function() representative_cdm(list()),
  cdm = function() cdm(list()),
  simultaneous_irf = function() simultaneous_irf(list()),
  simultaneous_cdm = function() simultaneous_cdm(list()),
  joint_hypothesis_irf = function() joint_hypothesis_irf(list()),
  joint_hypothesis_cdm = function() joint_hypothesis_cdm(list())
)
posterior_default_messages <- vapply(
  posterior_defaults,
  function(call) error_message(call()),
  character(1)
)
expect_true(all(grepl("posterior model object", posterior_default_messages, fixed = TRUE)))

response_defaults <- list(
  peak_response = function() peak_response(list()),
  duration_response = function() duration_response(list()),
  half_life_response = function() half_life_response(list()),
  time_to_threshold = function() time_to_threshold(list())
)
response_default_messages <- vapply(
  response_defaults,
  function(call) error_message(call()),
  character(1)
)
expect_true(all(grepl("PosteriorIR or PosteriorCDM", response_default_messages, fixed = TRUE)))

# Regression coverage for integer overflow during validation.
integer_messages <- c(
  error_message(bsvarPost:::validate_nonnegative_horizon(Inf, "test")),
  error_message(bsvarPost:::validate_positive_count(Inf, "test", arg = "count"))
)
expect_true(all(grepl("integer", integer_messages, fixed = TRUE)))

# Custom argument names remain actionable at public validation boundaries.
expect_true(
  grepl(
    "forecast_horizon",
    error_message(bsvarPost:::validate_horizon(-1, arg_name = "forecast_horizon")),
    fixed = TRUE
  )
)
