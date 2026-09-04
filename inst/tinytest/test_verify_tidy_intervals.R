Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)

manual_summary <- function(draws, variable = "ttr", shock = "ttr", horizon = 2) {
  values <- draws$value[
    draws$variable == variable &
      draws$shock == shock &
      draws$horizon == horizon
  ]
  c(
    mean = mean(values),
    median = stats::median(values),
    sd = stats::sd(values),
    lower = stats::quantile(values, 0.16, names = FALSE),
    upper = stats::quantile(values, 0.84, names = FALSE)
  )
}

check_tidy_summary <- function(tidy_fn) {
  draws <- tidy_fn(post, horizon = 2, probability = 0.68, draws = TRUE)
  summary <- tidy_fn(post, horizon = 2, probability = 0.68, draws = FALSE)
  row <- summary[
    summary$variable == "ttr" & summary$shock == "ttr" & summary$horizon == 2,
  ]
  list(
    observed = unname(unlist(row[c("mean", "median", "sd", "lower", "upper")])),
    expected = unname(manual_summary(draws)),
    draws = draws
  )
}

irf_check <- check_tidy_summary(tidy_irf)
cdm_check <- check_tidy_summary(tidy_cdm)
fevd_check <- check_tidy_summary(tidy_fevd)

expect_equal(irf_check$observed, irf_check$expected, tolerance = 1e-10)
expect_equal(cdm_check$observed, cdm_check$expected, tolerance = 1e-10)
expect_equal(fevd_check$observed, fevd_check$expected, tolerance = 1e-10)

# FEVD is reported in percentages. Check the invariant across every returned
# variable, horizon, and draw rather than repeating one assertion per group.
fevd_groups <- interaction(
  fevd_check$draws$variable,
  fevd_check$draws$horizon,
  fevd_check$draws$draw,
  drop = TRUE
)
fevd_sums <- tapply(fevd_check$draws$value, fevd_groups, sum)
expect_equal(as.numeric(fevd_sums), rep(100, length(fevd_sums)), tolerance = 1e-10)
