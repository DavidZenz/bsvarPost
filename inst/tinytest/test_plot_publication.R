data(us_fiscal_lsuw)
set.seed(61)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 5, thin = 1, show_progress = FALSE)

cmp_tbl <- compare_peak_response(base = post, alt = post, type = "irf", horizon = 2, variable = 1, shock = 1)
p_cmp <- publish_bsvar_plot(cmp_tbl, preset = "paper")
expect_true(inherits(p_cmp, "ggplot"))

rep_obj <- median_target_irf(post, horizon = 2)
p_rep <- publish_bsvar_plot(rep_obj, preset = "paper")
expect_true(inherits(p_rep, "ggplot"))
expect_true(identical(p_rep$labels$subtitle, "Method: median_target"))

sim_tbl <- simultaneous_irf(post, horizon = 2, variable = 1, shock = 1)
p_sim <- publish_bsvar_plot(sim_tbl, preset = "paper")
expect_true(inherits(p_sim, "ggplot"))
expect_true(grepl("^Coverage:", p_sim$labels$subtitle))

joint_tbl <- joint_hypothesis_irf(post, variable = 1, shock = 1, horizon = 0:1, relation = ">", value = 0)
p_joint <- publish_bsvar_plot(joint_tbl, preset = "paper")
expect_true(inherits(p_joint, "ggplot"))
expect_true(identical(p_joint$labels$subtitle, "Relation: >"))

hd_times <- unique(as.character(tidy_hd(post, draws = TRUE)$time))
event_start <- hd_times[1]
event_end <- hd_times[min(2, length(hd_times))]
hd_tbl <- tidy_hd_event(post, start = event_start, end = event_end)
p_hd <- publish_bsvar_plot(hd_tbl, preset = "paper")
expect_true(inherits(p_hd, "ggplot"))
expect_true(grepl("^Window:", p_hd$labels$subtitle))

rank_tbl <- shock_ranking(post, start = event_start, end = event_end, ranking = "absolute")
p_rank <- publish_bsvar_plot(rank_tbl, preset = "paper")
expect_true(inherits(p_rank, "ggplot"))

diag_tbl <- acceptance_diagnostics(
  estimate(
    specify_bsvarSIGN$new(us_fiscal_lsuw, p = 1, sign_irf = array(c(1, rep(NA_real_, 8)), dim = c(3, 3, 1))),
    S = 5,
    thin = 1,
    show_progress = FALSE
  )
)
p_diag <- publish_bsvar_plot(diag_tbl, preset = "paper")
expect_true(inherits(p_diag, "bsvar_diagnostics_plot"))
expect_true(identical(attr(p_diag, "plot_meta")$subtitle, "Stored-draw admissibility and sample-health diagnostics"))

expect_error(
  publish_bsvar_plot(1),
  "could not infer a supported output family",
  info = "publish_bsvar_plot: rejects unsupported input."
)
