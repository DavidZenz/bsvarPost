if (!requireNamespace("gt", quietly = TRUE)) {
  exit_file("gt not installed -- skipping gt smoke tests")
}

Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")
data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)

# as_gt on bsvar_post_tbl (tidy_irf output)
tbl <- tidy_irf(post, horizon = 2)
gt_tbl <- as_gt(tbl)
expect_true(inherits(gt_tbl, "gt_tbl"), info = "as_gt on bsvar_post_tbl returns gt_tbl")

# as_gt on report_bundle
hyp <- hypothesis_irf(post, horizon = 2, variable = 1, shock = 1, relation = ">")
bundle <- report_bundle(hyp, caption = "Test")
gt_bundle <- as_gt(bundle)
expect_true(inherits(gt_bundle, "gt_tbl"), info = "as_gt on report_bundle returns gt_tbl")

# as_gt on data.frame
df <- as.data.frame(tbl)
gt_df <- as_gt(df)
expect_true(inherits(gt_df, "gt_tbl"), info = "as_gt on data.frame returns gt_tbl")
