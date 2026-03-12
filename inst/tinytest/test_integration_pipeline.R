Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")
data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post1 <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)

# ---------------------------------------------------------------------------
# Pipeline 1: IRF full chain
# posterior -> tidy_irf -> compare_irf -> autoplot -> report_bundle -> as_kable
# ---------------------------------------------------------------------------

irf_tbl <- tidy_irf(post1, horizon = 3)
expect_true(nrow(irf_tbl) > 0, info = "Pipeline 1: tidy_irf returns non-empty table")

cmp_irf <- compare_irf(base = post1, alt = post2, horizon = 3)
expect_true("model" %in% names(cmp_irf), info = "Pipeline 1: compare_irf has model column")

p_irf <- ggplot2::autoplot(cmp_irf)
expect_true(inherits(p_irf, "ggplot"), info = "Pipeline 1: autoplot on compare_irf returns ggplot")

bundle_irf <- report_bundle(cmp_irf, caption = "IRF comparison")
expect_true(inherits(bundle_irf, "bsvar_report_bundle"), info = "Pipeline 1: report_bundle returns bsvar_report_bundle")

kbl <- as_kable(bundle_irf)
expect_true(inherits(kbl, "knitr_kable"), info = "Pipeline 1: as_kable on report_bundle returns knitr_kable")

# ---------------------------------------------------------------------------
# Pipeline 2: Hypothesis chain
# posterior -> hypothesis_irf -> plot_hypothesis
# ---------------------------------------------------------------------------

hyp <- hypothesis_irf(post1, horizon = 2, variable = 1, shock = 1, relation = ">")
expect_true(inherits(hyp, "bsvar_post_tbl"), info = "Pipeline 2: hypothesis_irf returns bsvar_post_tbl")

p_hyp <- plot_hypothesis(hyp)
expect_true(inherits(p_hyp, "ggplot"), info = "Pipeline 2: plot_hypothesis returns ggplot")

# ---------------------------------------------------------------------------
# Pipeline 3: Response summary chain
# posterior -> peak_response -> compare_peak_response -> autoplot
# ---------------------------------------------------------------------------

peak <- peak_response(post1, horizon = 3)
expect_true(inherits(peak, "bsvar_post_tbl"), info = "Pipeline 3: peak_response returns bsvar_post_tbl")

cmp_peak <- compare_peak_response(base = post1, alt = post2, horizon = 3)
expect_true(inherits(cmp_peak, "bsvar_post_tbl"), info = "Pipeline 3: compare_peak_response returns bsvar_post_tbl")

p_peak <- ggplot2::autoplot(cmp_peak)
expect_true(inherits(p_peak, "ggplot"), info = "Pipeline 3: autoplot on compare_peak_response returns ggplot")

# ---------------------------------------------------------------------------
# Pipeline 4: CDM chain
# posterior -> cdm -> tidy_cdm -> hypothesis_cdm
# ---------------------------------------------------------------------------

cdm_obj <- cdm(post1, horizon = 3)
expect_true(inherits(cdm_obj, "PosteriorCDM"), info = "Pipeline 4: cdm returns PosteriorCDM")

cdm_tbl <- tidy_cdm(post1, horizon = 3)
expect_true(inherits(cdm_tbl, "bsvar_post_tbl"), info = "Pipeline 4: tidy_cdm returns bsvar_post_tbl")

hyp_cdm <- hypothesis_cdm(post1, horizon = 2, variable = 1, shock = 1, relation = ">")
expect_true("posterior_prob" %in% names(hyp_cdm), info = "Pipeline 4: hypothesis_cdm has posterior_prob column")

# ---------------------------------------------------------------------------
# Pipeline 5: HD event chain
# posterior -> tidy_hd -> tidy_hd_event -> plot_hd_event
# ---------------------------------------------------------------------------

hd <- tidy_hd(post1)
expect_true("time" %in% names(hd), info = "Pipeline 5: tidy_hd has time column")

hd_times <- unique(as.character(hd$time))
first_time <- hd_times[1]
last_time <- hd_times[min(3, length(hd_times))]

hd_ev <- tidy_hd_event(post1, start = first_time, end = last_time, variables = 1)
expect_true(inherits(hd_ev, "bsvar_post_tbl"), info = "Pipeline 5: tidy_hd_event returns bsvar_post_tbl")

p_ev <- plot_hd_event(hd_ev)
expect_true(inherits(p_ev, "ggplot"), info = "Pipeline 5: plot_hd_event returns ggplot")
