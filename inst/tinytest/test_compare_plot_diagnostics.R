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

# Assert visible legend content, rather than only the composite's grob class.
legend_labels <- function(grob) {
  c(if (inherits(grob, "text")) as.character(grob$label),
    unlist(lapply(grob$grobs, legend_labels), use.names = FALSE),
    unlist(lapply(grob$children, legend_labels), use.names = FALSE))
}
expect_true(all(c("base", "alt") %in% legend_labels(p1)))
legend_data <- bsvarPost:::new_bsvar_post_tbl(data.frame(
  model = c("baseline", "alternative"), metric = "effective_sample_size",
  value = c(10, 30), flag = c(TRUE, FALSE), message = c("low ESS", "ok")),
  "acceptance_diagnostics", compare = TRUE)
legend_df <- bsvarPost:::attach_acceptance_diagnostic_metadata(legend_data)
for (flags in c(TRUE, FALSE)) {
  panel <- bsvarPost:::build_acceptance_diagnostics_panel(legend_df,
    preset = "default", base_size = 11, base_family = "",
    show_flags = flags, show_legend = TRUE)
  legend <- bsvarPost:::extract_acceptance_diagnostics_legend(panel)
  expect_true(all(c("baseline", "alternative") %in% legend_labels(legend)))
  if (flags) expect_true("Warning threshold exceeded" %in% legend_labels(legend))
}
# Legacy ggplot2 used a single guide-box; newer layouts include empty slots.
legacy <- list(layout = data.frame(name = "guide-box"), grobs = list(legend))
expect_identical(bsvarPost:::acceptance_diagnostics_legend_grob(legacy), legend)
positioned <- list(layout = data.frame(name = c("guide-box-right", "guide-box-bottom")),
  grobs = list(ggplot2::zeroGrob(), legend))
expect_identical(bsvarPost:::acceptance_diagnostics_legend_grob(positioned), legend)
positioned$grobs[[2]] <- ggplot2::zeroGrob()
expect_null(bsvarPost:::acceptance_diagnostics_legend_grob(positioned))

# All model glyphs share positions; subsets of flagged rows cannot re-dodge.
for (n in 1:3) {
  data <- data.frame(model = c("base", "alt", "third")[seq_len(n)],
    metric = "effective_sample_size", value = 10 * seq_len(n),
    flag = seq_len(n) == 1, message = "")
  df <- bsvarPost:::attach_acceptance_diagnostic_metadata(data)
  layers <- function(x) ggplot2::ggplot_build(bsvarPost:::build_acceptance_diagnostics_panel(x,
    preset = "default", base_size = 11, base_family = "", show_flags = TRUE, show_legend = TRUE))$data
  built <- layers(df)
  segments <- built[[1]]; points <- built[[2]]; flags <- built[[3]]
  expect_equal(segments$yend, segments$y)
  expect_equal(segments$yend, points$y[match(segments$xend, points$x)])
  expect_equal(flags$y, points$y[match(flags$x, points$x)])
  reordered <- layers(df[rev(seq_len(nrow(df))), ])[[2]]
  expect_equal(reordered$y[match(points$x, reordered$x)], points$y)
}

cmp_summary <- summary(cmp_diag)
draw_rows <- cmp_diag[cmp_diag$metric == "posterior_draws", , drop = FALSE]
expected_draws <- stats::setNames(draw_rows$value, draw_rows$model)
expect_equal(
  cmp_summary$posterior_draws,
  expected_draws,
  info = "summary.bsvar_post_tbl: comparison diagnostics retain one value per model."
)
expect_true(
  "model" %in% names(cmp_summary$warnings),
  info = "summary.bsvar_post_tbl: comparison warnings retain their model grouping."
)
summary_output <- capture.output(print(cmp_summary))
expect_true(
  all(vapply(names(expected_draws), function(model) {
    any(grepl(paste0("model: ", model), summary_output, fixed = TRUE))
  }, logical(1))),
  info = "print.SummaryAcceptanceDiagnostics: comparison output prints every model."
)

expect_error(
  plot_acceptance_diagnostics(cmp_diag, metrics = "does_not_exist"),
  "No diagnostics remain",
  info = "plot_acceptance_diagnostics: fails clearly after empty filtering."
)
