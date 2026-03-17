library(bsvarSIGNs)

data(optimism)
set.seed(29)
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
spec_a <- specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
spec_b <- specify_bsvarSIGN$new(optimism * 100, p = 2, sign_irf = sign_irf)
post_a <- estimate(spec_a, S = 5, thin = 1, show_progress = FALSE)
post_b <- estimate(spec_b, S = 5, thin = 1, show_progress = FALSE)

cmp_diag <- compare_acceptance_diagnostics(base = post_a, alt = post_b)
expect_true(inherits(cmp_diag, "bsvar_post_tbl"))
expect_true(isTRUE(attr(cmp_diag, "compare")))
expect_true(all(c("model", "metric", "value", "flag") %in% names(cmp_diag)))

p1 <- plot_acceptance_diagnostics(cmp_diag, metrics = c("effective_sample_size", "kernel_zero_share"))
p2 <- plot_acceptance_diagnostics(post_a, metrics = c("effective_sample_size", "kernel_zero_share"))
expect_true(inherits(p1, "bsvar_diagnostics_plot"))
expect_true(inherits(p2, "bsvar_diagnostics_plot"))
expect_true(inherits(p1, "grob"))
expect_true(inherits(p2, "grob"))

expect_error(
  plot_acceptance_diagnostics(cmp_diag, metrics = "does_not_exist"),
  "No diagnostics remain",
  info = "plot_acceptance_diagnostics: fails clearly after empty filtering."
)
