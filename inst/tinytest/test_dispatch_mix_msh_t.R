Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")

# ---------------------------------------------------------------------------
# PosteriorBSVARMIX fixture
# ---------------------------------------------------------------------------
set.seed(1)
spec_mix <- bsvars::specify_bsvar_mix$new(us_fiscal_lsuw, p = 1, M = 2)
post_mix  <- bsvars::estimate(spec_mix, S = 5, thin = 1, show_progress = FALSE)

# tidy_irf dispatches for PosteriorBSVARMIX
irf_mix <- tidy_irf(post_mix, horizon = 2)
expect_true(
  inherits(irf_mix, "bsvar_post_tbl"),
  info = "PosteriorBSVARMIX: tidy_irf dispatches and returns bsvar_post_tbl"
)
expect_true(
  nrow(irf_mix) > 0,
  info = "PosteriorBSVARMIX: tidy_irf result has rows"
)
expect_true(
  all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(irf_mix)),
  info = "PosteriorBSVARMIX: tidy_irf result has expected columns"
)

# hypothesis_irf dispatches for PosteriorBSVARMIX
hyp_mix <- hypothesis_irf(post_mix, variable = 1, shock = 1, horizon = 2, relation = ">", value = 0)
expect_true(
  is.data.frame(hyp_mix),
  info = "PosteriorBSVARMIX: hypothesis_irf dispatches and returns data.frame"
)
expect_true(
  "posterior_prob" %in% names(hyp_mix),
  info = "PosteriorBSVARMIX: hypothesis_irf result has posterior_prob column"
)

# representative_irf dispatches for PosteriorBSVARMIX
rep_mix <- representative_irf(post_mix, horizon = 2)
expect_true(
  is.list(rep_mix),
  info = "PosteriorBSVARMIX: representative_irf dispatches and returns list"
)
expect_true(
  !is.null(rep_mix$draw_index),
  info = "PosteriorBSVARMIX: representative_irf result has draw_index"
)
expect_true(
  inherits(rep_mix, "RepresentativeIR"),
  info = "PosteriorBSVARMIX: representative_irf result inherits RepresentativeIR"
)

# ---------------------------------------------------------------------------
# PosteriorBSVARMSH fixture
# ---------------------------------------------------------------------------
set.seed(1)
spec_msh <- bsvars::specify_bsvar_msh$new(us_fiscal_lsuw, p = 1, M = 2)
post_msh  <- bsvars::estimate(spec_msh, S = 5, thin = 1, show_progress = FALSE)

# tidy_irf dispatches for PosteriorBSVARMSH
irf_msh <- tidy_irf(post_msh, horizon = 2)
expect_true(
  inherits(irf_msh, "bsvar_post_tbl"),
  info = "PosteriorBSVARMSH: tidy_irf dispatches and returns bsvar_post_tbl"
)
expect_true(
  nrow(irf_msh) > 0,
  info = "PosteriorBSVARMSH: tidy_irf result has rows"
)
expect_true(
  all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(irf_msh)),
  info = "PosteriorBSVARMSH: tidy_irf result has expected columns"
)

# hypothesis_irf dispatches for PosteriorBSVARMSH
hyp_msh <- hypothesis_irf(post_msh, variable = 1, shock = 1, horizon = 2, relation = ">", value = 0)
expect_true(
  is.data.frame(hyp_msh),
  info = "PosteriorBSVARMSH: hypothesis_irf dispatches and returns data.frame"
)
expect_true(
  "posterior_prob" %in% names(hyp_msh),
  info = "PosteriorBSVARMSH: hypothesis_irf result has posterior_prob column"
)

# representative_irf dispatches for PosteriorBSVARMSH
rep_msh <- representative_irf(post_msh, horizon = 2)
expect_true(
  is.list(rep_msh),
  info = "PosteriorBSVARMSH: representative_irf dispatches and returns list"
)
expect_true(
  !is.null(rep_msh$draw_index),
  info = "PosteriorBSVARMSH: representative_irf result has draw_index"
)
expect_true(
  inherits(rep_msh, "RepresentativeIR"),
  info = "PosteriorBSVARMSH: representative_irf result inherits RepresentativeIR"
)

# ---------------------------------------------------------------------------
# PosteriorBSVART fixture
# ---------------------------------------------------------------------------
set.seed(1)
spec_t <- bsvars::specify_bsvar_t$new(us_fiscal_lsuw, p = 1)
post_t  <- bsvars::estimate(spec_t, S = 5, thin = 1, show_progress = FALSE)

# tidy_irf dispatches for PosteriorBSVART
irf_t <- tidy_irf(post_t, horizon = 2)
expect_true(
  inherits(irf_t, "bsvar_post_tbl"),
  info = "PosteriorBSVART: tidy_irf dispatches and returns bsvar_post_tbl"
)
expect_true(
  nrow(irf_t) > 0,
  info = "PosteriorBSVART: tidy_irf result has rows"
)
expect_true(
  all(c("variable", "shock", "horizon", "median", "lower", "upper") %in% names(irf_t)),
  info = "PosteriorBSVART: tidy_irf result has expected columns"
)

# hypothesis_irf dispatches for PosteriorBSVART
hyp_t <- hypothesis_irf(post_t, variable = 1, shock = 1, horizon = 2, relation = ">", value = 0)
expect_true(
  is.data.frame(hyp_t),
  info = "PosteriorBSVART: hypothesis_irf dispatches and returns data.frame"
)
expect_true(
  "posterior_prob" %in% names(hyp_t),
  info = "PosteriorBSVART: hypothesis_irf result has posterior_prob column"
)

# representative_irf dispatches for PosteriorBSVART
rep_t <- representative_irf(post_t, horizon = 2)
expect_true(
  is.list(rep_t),
  info = "PosteriorBSVART: representative_irf dispatches and returns list"
)
expect_true(
  !is.null(rep_t$draw_index),
  info = "PosteriorBSVART: representative_irf result has draw_index"
)
expect_true(
  inherits(rep_t, "RepresentativeIR"),
  info = "PosteriorBSVART: representative_irf result inherits RepresentativeIR"
)
