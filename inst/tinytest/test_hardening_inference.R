ir <- array(c(0, 1, 10), c(1, 1, 1, 3),
            dimnames = list("y", "s", "0", as.character(1:3)))
class(ir) <- c("PosteriorIR", "array")
band <- simultaneous_irf(ir, probability = 0.9)
expect_equal(band$critical_value, 9)
expect_equal(band$achieved_coverage, 1)
expect_true(mean(ir >= band$lower & ir <= band$upper) >= 0.9)
for (values in list(rep(3, 3), c(0, 0, 1, 1), 1:10)) {
  arr <- array(values, c(1, 1, 1, length(values)))
  class(arr) <- c("PosteriorIR", "array")
  for (probability in c(0.1, 0.5, 0.9, 0.99)) {
    expect_true(simultaneous_irf(arr, probability = probability)$achieved_coverage >= probability)
  }
}
expect_error(simultaneous_irf(ir, probability = 0), "strictly between")
set.seed(1)
coverage <- replicate(50, {
  extreme <- array(rnorm(10) * 1e150, c(1, 1, 1, 10))
  class(extreme) <- c("PosteriorIR", "array")
  interval <- simultaneous_irf(extreme, probability = 0.9)
  observed <- mean(extreme >= interval$lower & extreme <= interval$upper)
  stopifnot(observed == interval$achieved_coverage)
  observed
})
expect_true(all(coverage >= 0.9))
expect_error(half_life_response(ir, fraction = 2), "strictly between")
expect_error(peak_response(ir, variables = character()), "must not be empty")

paths <- array(1:12, c(2, 1, 2, 3),
               dimnames = list(c("a", "b"), "s", c("0", "1"), as.character(1:3)))
class(paths) <- c("PosteriorIR", "array")
pair <- hypothesis_irf(paths, variables = c("a", "b"), shocks = "s", horizon = 0:1,
  compare_to = list(variable = "a", shock = "s", horizon = 0), draws = TRUE)
expect_equal(nrow(pair), 12L)
expect_equal(pair$rhs_variable, rep("a", 12))
expect_equal(pair$rhs_horizon, rep(0, 12))
expect_equal(pair$gap, unname(c(paths[1, 1, 1, ] - paths[1, 1, 1, ],
                               paths[2, 1, 1, ] - paths[1, 1, 1, ],
                               paths[1, 1, 2, ] - paths[1, 1, 1, ],
                               paths[2, 1, 2, ] - paths[1, 1, 1, ])))
paired <- hypothesis_irf(paths, variables = c("a", "b"), shocks = "s", horizon = 1,
  compare_to = list(variable = c("b", "a"), shock = "s", horizon = 0), draws = TRUE)
expect_equal(paired$rhs_variable, rep(c("b", "a"), each = 3))
expect_equal(paired$gap, unname(c(paths[1, 1, 2, ] - paths[2, 1, 1, ],
                                paths[2, 1, 2, ] - paths[1, 1, 1, ])))

statement <- hypothesis_irf(paths, variables = "a", shocks = "s", horizon = 0:1)
plots <- list(ggplot2::autoplot(statement), report_bundle(statement)$plot, publish_bsvar_plot(statement))
for (p in plots) {
  expect_true(inherits(ggplot2::ggplot_build(p), "ggplot_built"))
  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path)
  print(p)
  grDevices::dev.off()
  expect_true(file.info(path)$size > 0)
  unlink(path)
}
expect_error(ggplot2::autoplot(pair), "Draw-level hypotheses")
expect_true(is.null(report_bundle(pair)$plot))
timing_comparison <- compare_peak_response(list(first = paths, second = paths))
expect_true(inherits(ggplot2::ggplot_build(publish_bsvar_plot(timing_comparison)), "ggplot_built"))
response_comparison <- compare_irf(list(first = paths, second = paths))
expect_true(inherits(ggplot2::ggplot_build(publish_bsvar_plot(response_comparison)), "ggplot_built"))
expect_true(inherits(ggplot2::ggplot_build(publish_bsvar_plot(report_bundle(statement))), "ggplot_built"))

forecast <- structure(list(forecasts = array(seq_len(36), c(1, 12, 3))), class = "Forecasts")
tbl <- tidy_forecast(forecast)
expect_true(is.numeric(tbl$horizon))
expect_equal(tbl$horizon, as.numeric(1:12))
expect_equal(ggplot2::ggplot_build(ggplot2::autoplot(tbl))$data[[2]]$x, as.numeric(1:12))

data(us_fiscal_lsuw, package = "bsvars")
set.seed(123)
post <- bsvars::estimate(bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1), S = 5, show_progress = FALSE)
named <- restriction_audit(post, list(structural_restriction("gdp", "gs", 1)))
indexed <- restriction_audit(post, list(structural_restriction(3, 2, 1)))
expect_equal(named$posterior_prob, indexed$posterior_prob)
expect_equal(unique(tidy_irf(post, horizon = 0)$horizon), 0)
expect_equal(dim(cdm(post, horizon = 0))[3], 1L)
expect_error(cdm(post, probability = 1), "strictly between")

data(optimism, package = "bsvarSIGNs")
set.seed(126)
spec <- suppressMessages(bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1,
  sign_irf = matrix(c(1, NA, NA, NA), 2, 2),
  sign_narrative = list(bsvarSIGNs::specify_narrative(start = 10, periods = 1, type = "S", sign = 1, shock = 1))))
sign_post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
expect_true(nrow(acceptance_diagnostics(sign_post)) > 0)
expect_true(inherits(most_likely_admissible_irf(sign_post), "RepresentativeIR"))
expect_error(narrative_restriction(-5), "positive")
expect_error(narrative_restriction(10, sign = 3), "-1 or 1")
expect_error(narrative_restriction(10, type = "A"), "variable index")
expect_error(restriction_audit(sign_post, list(narrative_restriction(1))), "outside")
expect_error(restriction_audit(sign_post, list(narrative_restriction(1e6))), "outside")
expect_error(acceptance_diagnostics(sign_post, sparse_threshold = 2), "finite scalar")
expect_error(bsvarPost:::bsvarsigns_native("_bsvarSIGNs_match_sign", diag(2)), "expects 2 arguments")
