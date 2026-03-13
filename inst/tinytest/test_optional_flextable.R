if (!requireNamespace("flextable", quietly = TRUE)) {
  exit_file("flextable not installed -- skipping flextable smoke tests")
}

Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")
data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)

# as_flextable on bsvar_post_tbl (tidy_irf output)
tbl <- tidy_irf(post, horizon = 2)
flex_tbl <- as_flextable(tbl)
expect_true(inherits(flex_tbl, "flextable"), info = "as_flextable on bsvar_post_tbl returns flextable")

# as_flextable on report_bundle
hyp <- hypothesis_irf(post, horizon = 2, variable = 1, shock = 1, relation = ">")
bundle <- report_bundle(hyp, caption = "Test")
flex_bundle <- as_flextable(bundle)
expect_true(inherits(flex_bundle, "flextable"), info = "as_flextable on report_bundle returns flextable")

# as_flextable on data.frame
df <- as.data.frame(tbl)
flex_df <- as_flextable(df)
expect_true(inherits(flex_df, "flextable"), info = "as_flextable on data.frame returns flextable")
