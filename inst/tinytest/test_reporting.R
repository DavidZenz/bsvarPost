data(us_fiscal_lsuw)
set.seed(52)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 5, thin = 1, show_progress = FALSE)

tbl <- compare_irf(base = post, alt = post, horizon = 2)

kbl <- as_kable(tbl, caption = "IRF comparison", digits = 3)
expect_true(inherits(kbl, "knitr_kable"))

bundle <- report_bundle(tbl, caption = "IRF comparison", digits = 2)
expect_true(inherits(bundle, "bsvar_report_bundle"))
expect_true(inherits(bundle$plot, "ggplot"))

bundle_kable <- as_kable(bundle)
expect_true(inherits(bundle_kable, "knitr_kable"))

csv_path <- tempfile(fileext = ".csv")
written_path <- write_bsvar_csv(tbl, csv_path)
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
