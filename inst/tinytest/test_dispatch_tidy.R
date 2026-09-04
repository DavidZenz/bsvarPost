Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec_sv <- bsvars::specify_bsvar_sv$new(us_fiscal_lsuw, p = 1)
post_sv <- bsvars::estimate(spec_sv, S = 2, thin = 1, show_progress = FALSE)

# One vertical smoke matrix protects the PosteriorBSVARSV registrations. The
# detailed numerical contracts for each function are covered by focused tests.
tidy_results <- list(
  tidy_irf(post_sv, horizon = 2),
  tidy_cdm(post_sv, horizon = 2),
  tidy_fevd(post_sv, horizon = 2),
  tidy_forecast(post_sv, horizon = 2),
  tidy_shocks(post_sv),
  tidy_hd(post_sv)
)
expect_true(all(vapply(tidy_results, inherits, logical(1), "bsvar_post_tbl")))

inference_results <- list(
  hypothesis_irf(post_sv, variable = 1, shock = 1, horizon = 1, relation = ">"),
  hypothesis_cdm(post_sv, variable = 1, shock = 1, horizon = 1, relation = ">"),
  joint_hypothesis_irf(post_sv, variable = 1, shock = 1, horizon = 0:1, relation = ">"),
  joint_hypothesis_cdm(post_sv, variable = 1, shock = 1, horizon = 0:1, relation = ">"),
  simultaneous_irf(post_sv, horizon = 2),
  simultaneous_cdm(post_sv, horizon = 2)
)
expect_true(all(vapply(inference_results, inherits, logical(1), "bsvar_post_tbl")))

representative_results <- list(
  representative_irf(post_sv, horizon = 2),
  representative_cdm(post_sv, horizon = 2)
)
expect_true(
  inherits(representative_results[[1]], "RepresentativeIR") &&
    inherits(representative_results[[2]], "RepresentativeCDM")
)

summary_results <- list(
  peak_response(post_sv, horizon = 2),
  duration_response(post_sv, horizon = 2, relation = ">", value = 0),
  half_life_response(post_sv, horizon = 2),
  time_to_threshold(post_sv, horizon = 2, relation = ">", value = 0)
)
expect_true(all(vapply(summary_results, inherits, logical(1), "bsvar_post_tbl")))
