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

flagged_tbl <- diag_tbl
flagged_tbl$flag <- FALSE
flagged_tbl$message <- ""
flagged_tbl$flag[1:2] <- TRUE
flagged_tbl$message[1:2] <- c("first warning", "second warning")
flagged_summary <- summary(flagged_tbl)
expect_equal(
  flagged_summary$warnings$metric,
  flagged_tbl$metric[1:2],
  info = "summary.bsvar_post_tbl: vectorized diagnostic flags are retained."
)
expect_equal(
  flagged_summary$warnings$message,
  c("first warning", "second warning"),
  info = "summary.bsvar_post_tbl: warning messages remain paired with flagged metrics."
)

metrics <- diag_tbl$metric
expect_true(all(c(
  "posterior_draws",
  "effective_sample_size",
  "irf_sign_restrictions",
  "zero_restrictions",
  "kernel_zero_share"
) %in% metrics))

diag_meta <- bsvarPost:::attach_acceptance_diagnostic_metadata(diag_tbl)
expect_true(all(c("family", "label", "family_order", "metric_order") %in% names(diag_meta)))
expect_true(all(c("Sampling", "Restrictions", "Kernel") %in% as.character(unique(diag_meta$family))))

draw_row <- subset(diag_tbl, metric == "posterior_draws")
expect_equal(draw_row$value[[1]], 5)

zero_row <- subset(diag_tbl, metric == "zero_restrictions")
expect_equal(zero_row$value[[1]], 1)

expect_error(
  acceptance_diagnostics(list()),
  "PosteriorBSVARSIGN",
  info = "acceptance_diagnostics: unsupported objects fail clearly."
)
