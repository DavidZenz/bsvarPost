library(bsvarSIGNs)

data(optimism)
set.seed(19)
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
spec <- specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
post <- estimate(spec, S = 5, thin = 1, show_progress = FALSE)

diag_tbl <- acceptance_diagnostics(post)
expect_true(inherits(diag_tbl, "bsvar_post_tbl"))
expect_true(all(c("metric", "value", "flag", "message") %in% names(diag_tbl)))

diag_summary <- summary(diag_tbl)
expect_true(inherits(diag_summary, "SummaryAcceptanceDiagnostics"))
expect_true(all(c("warnings", "diagnostics") %in% names(diag_summary)))

metrics <- diag_tbl$metric
expect_true(all(c(
  "posterior_draws",
  "effective_sample_size",
  "irf_sign_restrictions",
  "zero_restrictions",
  "kernel_zero_share"
) %in% metrics))

draw_row <- subset(diag_tbl, metric == "posterior_draws")
expect_equal(draw_row$value[[1]], 5)

zero_row <- subset(diag_tbl, metric == "zero_restrictions")
expect_equal(zero_row$value[[1]], 1)

expect_error(
  acceptance_diagnostics(list()),
  "PosteriorBSVARSIGN",
  info = "acceptance_diagnostics: unsupported objects fail clearly."
)
