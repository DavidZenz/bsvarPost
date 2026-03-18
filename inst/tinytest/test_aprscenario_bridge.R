Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 2, thin = 1, show_progress = FALSE)

apr_tbl <- as_apr_cond_forc(post, horizon = 2, origin = as.Date("2024-01-01"), frequency = "quarter")
expect_true(all(c("hor", "variable", "lower", "center", "upper") %in% names(apr_tbl)))
expect_true(inherits(apr_tbl$hor, "Date"))

back_tbl <- tidy_apr_forecast(apr_tbl, model = "apr")
expect_equal(attr(back_tbl, "object_type"), "forecast")
expect_true(all(c("model", "variable", "time", "median", "lower", "upper") %in% names(back_tbl)))
expect_equal(nrow(back_tbl), nrow(apr_tbl))

expect_error(
  as_apr_cond_forc(data.frame(variable = "y", lower = 0, upper = 1)),
  pattern = "no applicable method|forecast summary columns",
  info = "as_apr_cond_forc: malformed tidy input is rejected."
)

if (requireNamespace("APRScenario", quietly = TRUE)) {
  expect_error(
    apr_gen_mats(max_cores = 0),
    pattern = "positive integer|positive",
    info = "apr_gen_mats: invalid max_cores is rejected before calling APRScenario."
  )
} else {
  expect_error(
    apr_gen_mats(max_cores = 0),
    pattern = "APRScenario",
    info = "apr_gen_mats: missing optional dependency is reported clearly."
  )

  expect_error(
    apr_gen_mats(),
    pattern = "APRScenario",
    info = "apr_gen_mats: missing optional dependency is reported clearly."
  )
}
