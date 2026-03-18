Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post1 <- bsvars::estimate(spec, S = 2, thin = 1, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 2, thin = 1, show_progress = FALSE)

cmp_fevd <- compare_fevd(base = post1, alt = post2, horizon = 2)
cmp_forecast <- compare_forecast(base = post1, alt = post2, horizon = 2)
cmp_forecast_draws <- compare_forecast(base = post1, alt = post2, horizon = 2, draws = TRUE)

expect_true(inherits(cmp_fevd, "bsvar_post_tbl"))
expect_true(inherits(cmp_forecast, "bsvar_post_tbl"))
expect_equal(attr(cmp_fevd, "object_type"), "fevd")
expect_equal(attr(cmp_forecast, "object_type"), "forecast")
expect_true(isTRUE(attr(cmp_fevd, "compare")))
expect_true(isTRUE(attr(cmp_forecast, "compare")))
expect_true(isTRUE(attr(cmp_forecast_draws, "draws")))
expect_equal(sort(unique(cmp_fevd$model)), c("alt", "base"))
expect_equal(sort(unique(cmp_forecast$model)), c("alt", "base"))
expect_true(all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(cmp_fevd)))
expect_true(all(c("variable", "horizon", "median", "lower", "upper") %in% names(cmp_forecast)))
expect_true(all(c("draw", "value") %in% names(cmp_forecast_draws)))

expect_error(
  compare_fevd(),
  pattern = "At least one model object",
  info = "compare_fevd: empty model list is rejected cleanly."
)

expect_error(
  compare_forecast(list(base = post1, alt = NULL), horizon = 2),
  pattern = "non-NULL posterior objects",
  info = "compare_forecast: NULL model inputs are rejected early."
)
