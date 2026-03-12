Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# --- Shared PosteriorBSVAR fixture ---
data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)

# Test cells: diagonal variable/shock pairs at horizons 0, 4, 8
test_cells <- expand.grid(
  variable = c("ttr", "gs", "gdp"),
  horizon  = c(0, 4, 8),
  stringsAsFactors = FALSE
)
test_cells$shock <- test_cells$variable

# --- Test 1: tidy_irf credible intervals ---
tidy_irf_draws   <- tidy_irf(post_b, horizon = 8, probability = 0.68, draws = TRUE)
tidy_irf_summary <- tidy_irf(post_b, horizon = 8, probability = 0.68, draws = FALSE)

for (i in seq_len(nrow(test_cells))) {
  v <- test_cells$variable[i]
  s <- test_cells$shock[i]
  h <- test_cells$horizon[i]

  draws_vec <- tidy_irf_draws$value[
    tidy_irf_draws$variable == v &
    tidy_irf_draws$shock == s &
    tidy_irf_draws$horizon == h
  ]
  summ_row <- tidy_irf_summary[
    tidy_irf_summary$variable == v &
    tidy_irf_summary$shock == s &
    tidy_irf_summary$horizon == h,
  ]

  expect_equal(summ_row$mean,   mean(draws_vec),                                        tolerance = 1e-10)
  expect_equal(summ_row$median, stats::median(draws_vec),                                tolerance = 1e-10)
  expect_equal(summ_row$sd,     stats::sd(draws_vec),                                    tolerance = 1e-10)
  expect_equal(summ_row$lower,  stats::quantile(draws_vec, probs = 0.16, names = FALSE), tolerance = 1e-10)
  expect_equal(summ_row$upper,  stats::quantile(draws_vec, probs = 0.84, names = FALSE), tolerance = 1e-10)
}

# --- Test 2: tidy_cdm credible intervals ---
tidy_cdm_draws   <- tidy_cdm(post_b, horizon = 8, probability = 0.68, draws = TRUE)
tidy_cdm_summary <- tidy_cdm(post_b, horizon = 8, probability = 0.68, draws = FALSE)

for (i in seq_len(nrow(test_cells))) {
  v <- test_cells$variable[i]
  s <- test_cells$shock[i]
  h <- test_cells$horizon[i]

  draws_vec <- tidy_cdm_draws$value[
    tidy_cdm_draws$variable == v &
    tidy_cdm_draws$shock == s &
    tidy_cdm_draws$horizon == h
  ]
  summ_row <- tidy_cdm_summary[
    tidy_cdm_summary$variable == v &
    tidy_cdm_summary$shock == s &
    tidy_cdm_summary$horizon == h,
  ]

  expect_equal(summ_row$mean,   mean(draws_vec),                                        tolerance = 1e-10)
  expect_equal(summ_row$median, stats::median(draws_vec),                                tolerance = 1e-10)
  expect_equal(summ_row$sd,     stats::sd(draws_vec),                                    tolerance = 1e-10)
  expect_equal(summ_row$lower,  stats::quantile(draws_vec, probs = 0.16, names = FALSE), tolerance = 1e-10)
  expect_equal(summ_row$upper,  stats::quantile(draws_vec, probs = 0.84, names = FALSE), tolerance = 1e-10)
}

# --- Test 3: tidy_fevd credible intervals ---
tidy_fevd_draws   <- tidy_fevd(post_b, horizon = 8, probability = 0.68, draws = TRUE)
tidy_fevd_summary <- tidy_fevd(post_b, horizon = 8, probability = 0.68, draws = FALSE)

for (i in seq_len(nrow(test_cells))) {
  v <- test_cells$variable[i]
  s <- test_cells$shock[i]
  h <- test_cells$horizon[i]

  draws_vec <- tidy_fevd_draws$value[
    tidy_fevd_draws$variable == v &
    tidy_fevd_draws$shock == s &
    tidy_fevd_draws$horizon == h
  ]
  summ_row <- tidy_fevd_summary[
    tidy_fevd_summary$variable == v &
    tidy_fevd_summary$shock == s &
    tidy_fevd_summary$horizon == h,
  ]

  expect_equal(summ_row$mean,   mean(draws_vec),                                        tolerance = 1e-10)
  expect_equal(summ_row$median, stats::median(draws_vec),                                tolerance = 1e-10)
  expect_equal(summ_row$sd,     stats::sd(draws_vec),                                    tolerance = 1e-10)
  expect_equal(summ_row$lower,  stats::quantile(draws_vec, probs = 0.16, names = FALSE), tolerance = 1e-10)
  expect_equal(summ_row$upper,  stats::quantile(draws_vec, probs = 0.84, names = FALSE), tolerance = 1e-10)
}

# --- Test 4: FEVD row sums equal 100 (bsvars reports FEVD as percentages) ---
variables <- unique(tidy_fevd_draws$variable)
horizons  <- unique(tidy_fevd_draws$horizon)
draws_ids <- unique(tidy_fevd_draws$draw)

# Check representative sample: all variables x horizons 0, 4, 8 x draws 1, 15, 30
for (v in variables) {
  for (h in c(0, 4, 8)) {
    for (d in c(1, 15, 30)) {
      row_sum <- sum(tidy_fevd_draws$value[
        tidy_fevd_draws$variable == v &
        tidy_fevd_draws$horizon == h &
        tidy_fevd_draws$draw == d
      ])
      expect_equal(row_sum, 100, tolerance = 1e-10)
    }
  }
}
