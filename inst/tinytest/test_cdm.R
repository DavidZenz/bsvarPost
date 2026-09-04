Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

strip_attrs <- function(x) {
  attributes(x) <- NULL
  x
}

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec_b <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b <- bsvars::estimate(spec_b, S = 2, thin = 1, show_progress = FALSE)
irf_b <- bsvars::compute_impulse_responses(post_b, horizon = 2)
cdm_b <- cdm(post_b, horizon = 2)
manual_b <- irf_b
manual_b[, , 2, ] <- manual_b[, , 1, ] + irf_b[, , 2, ]
manual_b[, , 3, ] <- manual_b[, , 2, ] + irf_b[, , 3, ]
expect_equal(strip_attrs(cdm_b), strip_attrs(manual_b), tolerance = 1e-12)

data(optimism, package = "bsvarSIGNs")
set.seed(1)
spec_s <- suppressMessages(bsvarSIGNs::specify_bsvarSIGN$new(optimism, p = 1))
post_s <- bsvars::estimate(spec_s, S = 2, thin = 1, show_progress = FALSE)
cdm_s <- cdm(post_s, horizon = 2, scale_by = "shock_sd")
ysd <- apply(post_s$last_draw$data_matrices$Y, 1, sd, na.rm = TRUE)
irf_s <- bsvars::compute_impulse_responses(post_s, horizon = 2)
manual_s <- irf_s
manual_s[, , 2, ] <- manual_s[, , 1, ] + irf_s[, , 2, ]
manual_s[, , 3, ] <- manual_s[, , 2, ] + irf_s[, , 3, ]
for (j in seq_len(dim(manual_s)[2])) manual_s[, j, , ] <- manual_s[, j, , ] / ysd[j]
expect_equal(strip_attrs(cdm_s), strip_attrs(manual_s), tolerance = 1e-12)

synthetic_y <- matrix(
  c(1:4, 2:5, 3:6),
  nrow = 3,
  byrow = TRUE,
  dimnames = list(c("a", "b", "c"), NULL)
)
synthetic_model <- list(last_draw = list(data_matrices = list(Y = synthetic_y)))

expect_error(
  bsvarPost:::resolve_scale_factors(synthetic_model, 3, c("a", "b")),
  pattern = "length 1|one entry per shock",
  info = "resolve_scale_factors: partial per-shock selectors are rejected."
)
expect_error(
  bsvarPost:::resolve_scale_factors(synthetic_model, 3, "missing"),
  pattern = "Unknown.*scale_var",
  info = "resolve_scale_factors: unknown variable labels fail clearly."
)
expect_error(
  bsvarPost:::resolve_scale_factors(synthetic_model, 3, 1.5),
  pattern = "finite, whole-number indices",
  info = "resolve_scale_factors: fractional variable indices are rejected."
)

bad_y <- synthetic_y
bad_y[1, ] <- NA_real_
bad_model <- list(last_draw = list(data_matrices = list(Y = bad_y)))
expect_error(
  bsvarPost:::resolve_scale_factors(bad_model, 3, "a"),
  pattern = "finite and strictly positive",
  info = "resolve_scale_factors: missing scale factors are rejected."
)
bad_y[1, ] <- 1
bad_model$last_draw$data_matrices$Y <- bad_y
expect_error(
  bsvarPost:::resolve_scale_factors(bad_model, 3, "a"),
  pattern = "finite and strictly positive",
  info = "resolve_scale_factors: zero scale factors are rejected."
)

single_factor <- bsvarPost:::resolve_scale_factors(synthetic_model, 3, "a")
expect_equal(
  single_factor,
  rep(stats::sd(synthetic_y["a", ]), 3),
  info = "resolve_scale_factors: one selector is applied to every shock."
)
per_shock_factors <- bsvarPost:::resolve_scale_factors(synthetic_model, 3, c("a", "b", "c"))
expect_equal(
  per_shock_factors,
  unname(apply(synthetic_y, 1, stats::sd)),
  info = "resolve_scale_factors: one valid selector per shock is supported."
)
