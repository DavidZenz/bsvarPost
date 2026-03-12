Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# ---- Two-model PosteriorBSVAR fixture (S=30) ----
data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_a <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)
set.seed(2027)
post_b <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)

# ---- Test 1: compare_irf equals rbind of tidy_irf ----
comp_irf <- compare_irf(m1 = post_a, m2 = post_b, horizon = 4, probability = 0.68)
tidy_a   <- tidy_irf(post_a, horizon = 4, probability = 0.68, model = "m1")
tidy_b   <- tidy_irf(post_b, horizon = 4, probability = 0.68, model = "m2")

# Model labels
expect_equal(sort(unique(comp_irf$model)), c("m1", "m2"))

# Row count
expect_equal(nrow(comp_irf), nrow(tidy_a) + nrow(tidy_b))

# Numerical values for m1
comp_m1 <- comp_irf[comp_irf$model == "m1", ]
expect_equal(comp_m1$median, tidy_a$median, tolerance = 1e-10)
expect_equal(comp_m1$mean,   tidy_a$mean,   tolerance = 1e-10)
expect_equal(comp_m1$lower,  tidy_a$lower,  tolerance = 1e-10)
expect_equal(comp_m1$upper,  tidy_a$upper,  tolerance = 1e-10)

# Numerical values for m2
comp_m2 <- comp_irf[comp_irf$model == "m2", ]
expect_equal(comp_m2$median, tidy_b$median, tolerance = 1e-10)
expect_equal(comp_m2$mean,   tidy_b$mean,   tolerance = 1e-10)
expect_equal(comp_m2$lower,  tidy_b$lower,  tolerance = 1e-10)
expect_equal(comp_m2$upper,  tidy_b$upper,  tolerance = 1e-10)

# Compare attribute
expect_true(isTRUE(attr(comp_irf, "compare")))

# ---- Test 2: compare_cdm equals rbind of tidy_cdm ----
comp_cdm <- compare_cdm(m1 = post_a, m2 = post_b, horizon = 4, probability = 0.68)
tidy_cdm_a <- tidy_cdm(post_a, horizon = 4, probability = 0.68, model = "m1")
tidy_cdm_b <- tidy_cdm(post_b, horizon = 4, probability = 0.68, model = "m2")

expect_equal(sort(unique(comp_cdm$model)), c("m1", "m2"))
expect_equal(nrow(comp_cdm), nrow(tidy_cdm_a) + nrow(tidy_cdm_b))

comp_cdm_m1 <- comp_cdm[comp_cdm$model == "m1", ]
expect_equal(comp_cdm_m1$median, tidy_cdm_a$median, tolerance = 1e-10)
expect_equal(comp_cdm_m1$mean,   tidy_cdm_a$mean,   tolerance = 1e-10)
expect_equal(comp_cdm_m1$lower,  tidy_cdm_a$lower,  tolerance = 1e-10)
expect_equal(comp_cdm_m1$upper,  tidy_cdm_a$upper,  tolerance = 1e-10)

comp_cdm_m2 <- comp_cdm[comp_cdm$model == "m2", ]
expect_equal(comp_cdm_m2$median, tidy_cdm_b$median, tolerance = 1e-10)
expect_equal(comp_cdm_m2$mean,   tidy_cdm_b$mean,   tolerance = 1e-10)
expect_equal(comp_cdm_m2$lower,  tidy_cdm_b$lower,  tolerance = 1e-10)
expect_equal(comp_cdm_m2$upper,  tidy_cdm_b$upper,  tolerance = 1e-10)

expect_true(isTRUE(attr(comp_cdm, "compare")))

# ---- Test 3: compare_fevd equals rbind of tidy_fevd ----
comp_fevd <- compare_fevd(m1 = post_a, m2 = post_b, horizon = 4, probability = 0.68)
tidy_fevd_a <- tidy_fevd(post_a, horizon = 4, probability = 0.68, model = "m1")
tidy_fevd_b <- tidy_fevd(post_b, horizon = 4, probability = 0.68, model = "m2")

expect_equal(sort(unique(comp_fevd$model)), c("m1", "m2"))
expect_equal(nrow(comp_fevd), nrow(tidy_fevd_a) + nrow(tidy_fevd_b))

comp_fevd_m1 <- comp_fevd[comp_fevd$model == "m1", ]
expect_equal(comp_fevd_m1$median, tidy_fevd_a$median, tolerance = 1e-10)
expect_equal(comp_fevd_m1$mean,   tidy_fevd_a$mean,   tolerance = 1e-10)
expect_equal(comp_fevd_m1$lower,  tidy_fevd_a$lower,  tolerance = 1e-10)
expect_equal(comp_fevd_m1$upper,  tidy_fevd_a$upper,  tolerance = 1e-10)

comp_fevd_m2 <- comp_fevd[comp_fevd$model == "m2", ]
expect_equal(comp_fevd_m2$median, tidy_fevd_b$median, tolerance = 1e-10)
expect_equal(comp_fevd_m2$mean,   tidy_fevd_b$mean,   tolerance = 1e-10)
expect_equal(comp_fevd_m2$lower,  tidy_fevd_b$lower,  tolerance = 1e-10)
expect_equal(comp_fevd_m2$upper,  tidy_fevd_b$upper,  tolerance = 1e-10)

expect_true(isTRUE(attr(comp_fevd, "compare")))

# ---- Test 4: compare_restrictions equals rbind of restriction_audit ----
restr <- list(
  irf_restriction(variable = 1, shock = 1, horizon = 0, sign = 1),
  structural_restriction(variable = 1, shock = 1, sign = 1)
)
comp_restr <- compare_restrictions(m1 = post_a, m2 = post_b, restrictions = restr)
audit_a    <- restriction_audit(post_a, restrictions = restr, model = "m1")
audit_b    <- restriction_audit(post_b, restrictions = restr, model = "m2")

expect_equal(nrow(comp_restr), nrow(audit_a) + nrow(audit_b))
expect_equal(sort(unique(comp_restr$model)), c("m1", "m2"))

comp_restr_m1 <- comp_restr[comp_restr$model == "m1", ]
expect_equal(comp_restr_m1$posterior_prob, audit_a$posterior_prob, tolerance = 1e-10)
expect_equal(comp_restr_m1$mean,           audit_a$mean,           tolerance = 1e-10)
expect_equal(comp_restr_m1$median,         audit_a$median,         tolerance = 1e-10)

comp_restr_m2 <- comp_restr[comp_restr$model == "m2", ]
expect_equal(comp_restr_m2$posterior_prob, audit_b$posterior_prob, tolerance = 1e-10)
expect_equal(comp_restr_m2$mean,           audit_b$mean,           tolerance = 1e-10)
expect_equal(comp_restr_m2$median,         audit_b$median,         tolerance = 1e-10)

expect_true(isTRUE(attr(comp_restr, "compare")))

# ---- Test 5: compare_peak_response equals rbind of peak_response ----
comp_peak <- compare_peak_response(m1 = post_a, m2 = post_b, horizon = 4, variable = 1, shock = 1)
peak_a    <- peak_response(post_a, horizon = 4, type = "irf", variable = 1, shock = 1, model = "m1")
peak_b    <- peak_response(post_b, horizon = 4, type = "irf", variable = 1, shock = 1, model = "m2")

expect_equal(sort(unique(comp_peak$model)), c("m1", "m2"))
expect_equal(nrow(comp_peak), nrow(peak_a) + nrow(peak_b))

comp_peak_m1 <- comp_peak[comp_peak$model == "m1", ]
expect_equal(comp_peak_m1$median_value,   peak_a$median_value,   tolerance = 1e-10)
expect_equal(comp_peak_m1$median_horizon, peak_a$median_horizon, tolerance = 1e-10)
expect_equal(comp_peak_m1$mean_value,     peak_a$mean_value,     tolerance = 1e-10)

comp_peak_m2 <- comp_peak[comp_peak$model == "m2", ]
expect_equal(comp_peak_m2$median_value,   peak_b$median_value,   tolerance = 1e-10)
expect_equal(comp_peak_m2$median_horizon, peak_b$median_horizon, tolerance = 1e-10)
expect_equal(comp_peak_m2$mean_value,     peak_b$mean_value,     tolerance = 1e-10)

expect_true(isTRUE(attr(comp_peak, "compare")))

# ---- Test 6: compare_duration_response equals rbind of duration_response ----
comp_dur <- compare_duration_response(m1 = post_a, m2 = post_b, horizon = 4,
                                       variable = 1, shock = 1, relation = ">",
                                       value = 0, mode = "total")
dur_a    <- duration_response(post_a, horizon = 4, type = "irf", variable = 1, shock = 1,
                               relation = ">", value = 0, mode = "total", model = "m1")
dur_b    <- duration_response(post_b, horizon = 4, type = "irf", variable = 1, shock = 1,
                               relation = ">", value = 0, mode = "total", model = "m2")

expect_equal(sort(unique(comp_dur$model)), c("m1", "m2"))
expect_equal(nrow(comp_dur), nrow(dur_a) + nrow(dur_b))

comp_dur_m1 <- comp_dur[comp_dur$model == "m1", ]
expect_equal(comp_dur_m1$median_duration, dur_a$median_duration, tolerance = 1e-10)
expect_equal(comp_dur_m1$mean_duration,   dur_a$mean_duration,   tolerance = 1e-10)

comp_dur_m2 <- comp_dur[comp_dur$model == "m2", ]
expect_equal(comp_dur_m2$median_duration, dur_b$median_duration, tolerance = 1e-10)
expect_equal(comp_dur_m2$mean_duration,   dur_b$mean_duration,   tolerance = 1e-10)

expect_true(isTRUE(attr(comp_dur, "compare")))

# ---- Test 7: Model naming from arguments ----
comp_named <- compare_irf(baseline = post_a, alternative = post_b, horizon = 4)
expect_equal(sort(unique(comp_named$model)), c("alternative", "baseline"))
