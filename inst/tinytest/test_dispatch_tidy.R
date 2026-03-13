Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec_sv <- bsvars::specify_bsvar_sv$new(us_fiscal_lsuw, p = 1)
post_sv <- bsvars::estimate(spec_sv, S = 5, thin = 1, show_progress = FALSE)

# tidy_irf dispatches for PosteriorBSVARSV
irf_sv <- tidy_irf(post_sv, horizon = 2)
expect_true(inherits(irf_sv, "bsvar_post_tbl"))
expect_true(nrow(irf_sv) > 0)
expect_true(all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(irf_sv)))

# tidy_cdm dispatches for PosteriorBSVARSV
cdm_sv <- tidy_cdm(post_sv, horizon = 2)
expect_true(inherits(cdm_sv, "bsvar_post_tbl"))
expect_true(nrow(cdm_sv) > 0)
expect_true(all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(cdm_sv)))

# tidy_fevd dispatches for PosteriorBSVARSV
fevd_sv <- tidy_fevd(post_sv, horizon = 2)
expect_true(inherits(fevd_sv, "bsvar_post_tbl"))
expect_true(nrow(fevd_sv) > 0)
expect_true(all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(fevd_sv)))

# tidy_forecast dispatches for PosteriorBSVARSV
fc_sv <- tidy_forecast(post_sv, horizon = 2)
expect_true(inherits(fc_sv, "bsvar_post_tbl"))
expect_true(nrow(fc_sv) > 0)
expect_true("variable" %in% names(fc_sv))

# tidy_shocks dispatches for PosteriorBSVARSV
sh_sv <- tidy_shocks(post_sv)
expect_true(inherits(sh_sv, "bsvar_post_tbl"))
expect_true(nrow(sh_sv) > 0)
expect_true(all(c("variable", "median", "lower", "upper") %in% names(sh_sv)))

# tidy_hd dispatches for PosteriorBSVARSV
hd_sv <- tidy_hd(post_sv)
expect_true(inherits(hd_sv, "bsvar_post_tbl"))
expect_true(nrow(hd_sv) > 0)
expect_true(all(c("variable", "shock", "median", "lower", "upper") %in% names(hd_sv)))

# Variable names are consistent with model input
expected_names <- rownames(post_sv$last_draw$data_matrices$Y)
expect_equal(sort(unique(irf_sv$variable)), sort(expected_names))
expect_equal(sort(unique(irf_sv$shock)), sort(expected_names))
expect_equal(sort(unique(cdm_sv$shock)), sort(expected_names))
expect_equal(sort(unique(fevd_sv$shock)), sort(expected_names))
expect_equal(sort(unique(sh_sv$variable)), sort(expected_names))
expect_equal(sort(unique(hd_sv$variable)), sort(expected_names))
expect_equal(sort(unique(hd_sv$shock)), sort(expected_names))
