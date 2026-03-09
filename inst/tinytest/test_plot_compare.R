data(us_fiscal_lsuw)
set.seed(41)
spec_a <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
spec_b <- specify_bsvar$new(us_fiscal_lsuw, p = 2)
post_a <- estimate(spec_a, S = 5, thin = 1, show_progress = FALSE)
post_b <- estimate(spec_b, S = 5, thin = 1, show_progress = FALSE)

cmp_peak <- compare_peak_response(base = post_a, alt = post_b, type = "irf", horizon = 4, variable = 1, shock = 1)
cmp_duration <- compare_duration_response(base = post_a, alt = post_b, type = "cdm", horizon = 4,
                                          variable = 1, shock = 1, relation = ">", value = 0, mode = "total")
cmp_restr <- compare_restrictions(
  base = post_a,
  alt = post_b,
  restrictions = list(irf_restriction(variable = 1, shock = 1, horizon = 0, sign = 1))
)

p_peak <- plot_compare_response(cmp_peak)
p_duration <- plot_compare_response(cmp_duration)
p_restr <- plot_compare_restrictions(cmp_restr)

expect_true(inherits(p_peak, "ggplot"))
expect_true(inherits(p_duration, "ggplot"))
expect_true(inherits(p_restr, "ggplot"))

expect_error(
  plot_compare_response(cmp_restr),
  "supports compare tables",
  info = "plot_compare_response: rejects non-response comparison tables."
)

expect_error(
  plot_compare_restrictions(cmp_peak),
  "requires a restriction-audit comparison table",
  info = "plot_compare_restrictions: rejects non-restriction compare tables."
)
