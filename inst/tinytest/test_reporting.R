data(us_fiscal_lsuw)
set.seed(52)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 5, thin = 1, show_progress = FALSE)

tbl <- compare_irf(base = post, alt = post, horizon = 2)

full_tbl <- report_table(tbl, preset = "default", digits = 4)
compact_tbl <- report_table(tbl, preset = "compact", digits = 4)
expect_true(is.data.frame(full_tbl))
expect_true(is.data.frame(compact_tbl))
expect_true(ncol(compact_tbl) <= ncol(full_tbl))
expect_true(identical(names(compact_tbl)[1:4], c("Model", "Variable", "Shock", "Horizon")))

kbl <- as_kable(tbl, caption = "IRF comparison", digits = 3)
expect_true(inherits(kbl, "knitr_kable"))

bundle <- report_bundle(tbl, caption = "IRF comparison", digits = 2, preset = "compact")
expect_true(inherits(bundle, "bsvar_report_bundle"))
expect_true(inherits(bundle$plot, "ggplot"))
expect_true(identical(names(bundle$table)[1:4], c("Model", "Variable", "Shock", "Horizon")))

bundle_kable <- as_kable(bundle)
expect_true(inherits(bundle_kable, "knitr_kable"))

rep_obj <- median_target_irf(post, horizon = 2)
rep_bundle <- report_bundle(rep_obj, caption = "Representative IRF")
expect_true(inherits(rep_bundle, "bsvar_report_bundle"))
expect_true(inherits(rep_bundle$plot, "ggplot"))
expect_true(all(c("Draw index", "Method", "Score") %in% names(rep_bundle$table)))

diag_tbl <- acceptance_diagnostics(
  estimate(
    specify_bsvarSIGN$new(us_fiscal_lsuw, p = 1, sign_irf = array(c(1, rep(NA_real_, 8)), dim = c(3, 3, 1))),
    S = 5,
    thin = 1,
    show_progress = FALSE
  )
)
diag_bundle <- report_bundle(diag_tbl, caption = "Acceptance diagnostics")
expect_true(inherits(diag_bundle$plot, "bsvar_diagnostics_plot") || inherits(diag_bundle$plot, "ggplot"))
expect_true("Metric" %in% names(diag_bundle$table))

sim_tbl <- simultaneous_irf(post, horizon = 2, variable = 1, shock = 1)
sim_bundle <- report_bundle(sim_tbl, caption = "Simultaneous bands", preset = "compact")
expect_true(inherits(sim_bundle$plot, "ggplot"))
expect_true(all(c("Median", "Lower", "Upper", "Critical value") %in% names(sim_bundle$table)))

joint_tbl <- joint_hypothesis_irf(post, variable = 1, shock = 1, horizon = 0:1, relation = ">", value = 0)
joint_bundle <- report_bundle(joint_tbl, caption = "Joint hypothesis", preset = "compact")
expect_true(inherits(joint_bundle$plot, "ggplot"))
expect_true(all(c("Posterior probability", "Constraints") %in% names(joint_bundle$table)))

hd_times <- unique(as.character(tidy_hd(post, draws = TRUE)$time))
event_start <- hd_times[1]
event_end <- hd_times[min(2, length(hd_times))]

hd_event_tbl <- tidy_hd_event(post, start = event_start, end = event_end)
hd_event_bundle <- report_bundle(hd_event_tbl, preset = "compact")
expect_true(inherits(hd_event_bundle$plot, "ggplot"))
expect_true(identical(hd_event_bundle$caption, "Event-window historical decomposition"))

rank_tbl <- shock_ranking(post, start = event_start, end = event_end, ranking = "absolute")
rank_bundle <- report_bundle(rank_tbl, preset = "compact")
expect_true(inherits(rank_bundle$plot, "ggplot"))
expect_true(identical(rank_bundle$caption, "Shock ranking by event contribution"))

csv_path <- tempfile(fileext = ".csv")
written_path <- write_bsvar_csv(tbl, csv_path, preset = "compact")
expect_true(file.exists(csv_path))
expect_true(identical(normalizePath(csv_path, winslash = "/", mustWork = FALSE), written_path))

bundle_csv_path <- tempfile(fileext = ".csv")
bundle_written_path <- write_bsvar_csv(bundle, bundle_csv_path)
expect_true(file.exists(bundle_csv_path))
expect_true(identical(normalizePath(bundle_csv_path, winslash = "/", mustWork = FALSE), bundle_written_path))

if (requireNamespace("gt", quietly = TRUE)) {
  gt_tbl <- as_gt(tbl, caption = "IRF comparison", digits = 2)
  expect_true(inherits(gt_tbl, "gt_tbl"))
} else {
  expect_error(
    as_gt(tbl),
    "requires the optional package `gt`",
    info = "as_gt: clean error when gt is absent."
  )
}

if (requireNamespace("flextable", quietly = TRUE)) {
  flex_tbl <- as_flextable(tbl, caption = "IRF comparison", digits = 2)
  expect_true(inherits(flex_tbl, "flextable"))
} else {
  expect_error(
    as_flextable(tbl),
    "requires the optional package `flextable`",
    info = "as_flextable: clean error when flextable is absent."
  )
}

expect_error(
  as_kable(1),
  "supports bsvarPost tables and data frames only",
  info = "as_kable: rejects unsupported objects."
)

expect_error(
  report_table(1),
  "supports bsvarPost tables and data frames only",
  info = "report_table: rejects unsupported objects."
)
