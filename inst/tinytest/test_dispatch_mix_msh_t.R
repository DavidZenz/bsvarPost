Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")

specifications <- list(
  MIX = bsvars::specify_bsvar_mix$new(us_fiscal_lsuw, p = 1, M = 2),
  MSH = bsvars::specify_bsvar_msh$new(us_fiscal_lsuw, p = 1, M = 2),
  T = bsvars::specify_bsvar_t$new(us_fiscal_lsuw, p = 1)
)

set.seed(1)
posteriors <- lapply(specifications, function(spec) {
  bsvars::estimate(spec, S = 2, thin = 1, show_progress = FALSE)
})

# These posterior classes share implementations. A compact public-API smoke
# test per class catches dispatch or upstream-shape regressions without cloning
# every numerical contract for every alias.
for (model_name in names(posteriors)) {
  post <- posteriors[[model_name]]
  tidy_result <- tidy_irf(post, horizon = 2)
  hypothesis_result <- hypothesis_irf(
    post,
    variable = 1,
    shock = 1,
    horizon = 1,
    relation = ">"
  )
  representative_result <- representative_irf(post, horizon = 2)

  expect_true(
    inherits(tidy_result, "bsvar_post_tbl") &&
      inherits(hypothesis_result, "bsvar_post_tbl") &&
      inherits(representative_result, "RepresentativeIR"),
    info = paste(model_name, "posterior dispatches through core public APIs")
  )
}
