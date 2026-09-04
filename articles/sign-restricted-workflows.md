# Sign-Restricted Workflows

This article starts with an estimated `PosteriorBSVARSIGN`. It assumes
you already know how to encode sign, zero, structural, or narrative
restrictions with [`bsvarSIGNs`](https://bsvars.org/bsvarSIGNs/). The
focus here is what to do next: select a coherent admissible draw, audit
the fitted restrictions, and check whether the stored posterior sample
provides healthy support.

These are three different questions:

| Question | Function | What the result means |
|----|----|----|
| Which admissible draw should represent the posterior? | [`most_likely_admissible_irf()`](https://davidzenz.github.io/bsvarPost/reference/most_likely_admissible_irf.md) or [`most_likely_admissible_cdm()`](https://davidzenz.github.io/bsvarPost/reference/most_likely_admissible_cdm.md) | One stored draw, selected using its admissibility weight |
| How often does each restriction hold? | [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md) | Posterior satisfaction probability for each fitted restriction |
| Is the stored sample well supported? | [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md) | ESS, search settings, restriction counts, and admissibility-weight diagnostics |

None substitutes for the others. A representative draw is not evidence
that every restriction is strongly supported, while a high satisfaction
probability does not show that the effective sample size or
admissibility support is healthy.

## Start from a sign-restricted posterior

The smallest reproducible handoff uses the `optimism` example from
`bsvarSIGNs`. The restriction construction and estimation are shown only
to make the object provenance explicit; replace `post_sign` with your
own fitted posterior.

``` r

data("optimism", package = "bsvarSIGNs")

sign_irf <- matrix(c(0, 1, rep(NA_real_, 23)), 5, 5)
spec_sign <- bsvarSIGNs::specify_bsvarSIGN$new(optimism * 100, p = 4,
  sign_irf = sign_irf)

set.seed(123)
post_sign <- bsvars::estimate(spec_sign, S = 2000, thin = 1,
  show_progress = FALSE)
```

All remaining chunks are non-evaluated because the package does not
bundle a sign-posterior fixture. They are complete calls that can be run
after the fit above.

## Choose one representative admissible draw

[`most_likely_admissible_irf()`](https://davidzenz.github.io/bsvarPost/reference/most_likely_admissible_irf.md)
ranks the stored draws by the admissibility kernel used for the fitted
sign model. If several draws share the highest weight, closeness to the
posterior median target breaks the tie. The result is one internally
coherent draw, not a path assembled from marginal quantiles.

``` r

rep_irf <- most_likely_admissible_irf(post_sign, horizon = 12)

rep_irf$draw_index
rep_irf$score

rep_path <- subset(summary(rep_irf),
  variable == "productivity" & shock == "productivity" &
    horizon %in% c(0, 4, 8, 12),
  select = c(variable, shock, horizon, median, draw_index, method, score))
rep_path
```

Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html) to compare
the selected path with the posterior pointwise summary. The red path is
the selected stored draw; it should not be read as an additional
credible interval or as a model-selection result.

``` r

plot(rep_irf)
```

The cumulative counterpart applies the same selection rule after
accumulating responses draw by draw:

``` r

rep_cdm <- most_likely_admissible_cdm(post_sign, horizon = 12)
summary(rep_cdm)
plot(rep_cdm)
```

Use the IRF or CDM version according to the research quantity being
reported; do not treat the two selected draws as necessarily
interchangeable.

## Audit restriction satisfaction

For a `PosteriorBSVARSIGN`,
[`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md)
extracts the fitted IRF, zero, structural, and narrative restrictions
from the identification scheme. It then reports the share of stored
posterior draws satisfying each restriction.

``` r

audit <- restriction_audit(post_sign, zero_tol = 1e-6)
audit_focus <- audit[, c("restriction_type", "restriction", "relation",
                         "posterior_prob")]
audit_focus
```

`zero_tol` defines how close an audited response must be to zero. Set it
to a scale-appropriate numerical tolerance and report that choice when
zero restrictions matter.

The most direct display is a probability bar chart. Pretty labels
improve legibility without changing the underlying restriction
definitions.

``` r

plot_restriction_audit(audit, label_style = "pretty",
  restriction_types = c("irf_sign", "irf_zero"))
```

The audit describes satisfaction under the fitted posterior and the
chosen tolerance. It is not a sampler acceptance rate and does not
diagnose whether admissible draws are concentrated in a thin region.

## Diagnose the stored sample

[`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md)
summarizes information recoverable from the saved posterior: draw count,
effective sample size, `max_tries`, restriction counts, and the
distribution of admissibility weights.

``` r

diag <- acceptance_diagnostics(post_sign, ess_threshold = 100,
  sparse_threshold = 0.10)

subset(diag,
  metric %in% c(
    "posterior_draws", "effective_sample_size", "max_tries",
    "kernel_zero_share", "kernel_cv"),
  select = c(metric, value, flag, message))
```

Start with `effective_sample_size` and `kernel_zero_share`. The first
flags a small effective stored sample; the second records the share of
near-zero admissibility weights. `kernel_cv` describes weight
dispersion, while the restriction counts and `max_tries` provide context
for how demanding the identification search was.

The thresholds are review aids, not universal pass/fail rules. Most
importantly, these diagnostics cannot reconstruct the sampler’s complete
proposal and rejection history from the saved posterior.

``` r

plot_acceptance_diagnostics(diag,
  metrics = c("effective_sample_size", "kernel_zero_share", "kernel_cv"),
  title = "Stored-sample diagnostics")
```

## Compare sign-restricted specifications

Fit alternatives with the same variables and comparable identifying
restrictions. Named arguments become stable model labels in both
comparison tables.

``` r

spec_sign_alt <- bsvarSIGNs::specify_bsvarSIGN$new(optimism * 100, p = 2,
  sign_irf = sign_irf)

set.seed(456)
post_sign_alt <- bsvars::estimate(spec_sign_alt, S = 2000, thin = 1,
  show_progress = FALSE)
```

Compare restriction satisfaction separately from sample health:

``` r

restriction_comparison <- compare_restrictions(baseline = post_sign,
  shorter_lag = post_sign_alt, zero_tol = 1e-6)

diagnostic_comparison <- compare_acceptance_diagnostics(
  baseline = post_sign,
  shorter_lag = post_sign_alt,
  ess_threshold = 100,
  sparse_threshold = 0.10)
```

[`compare_restrictions()`](https://davidzenz.github.io/bsvarPost/reference/compare_restrictions.md)
aligns posterior satisfaction probabilities by model;
[`compare_acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/compare_acceptance_diagnostics.md)
aligns diagnostic metrics. Differences in either table describe fitted
posteriors and stored samples—they do not by themselves rank the
economic plausibility of the specifications.

``` r

plot_compare_restrictions(restriction_comparison,
  restriction_types = c("irf_sign", "irf_zero"))

plot_acceptance_diagnostics(
  diagnostic_comparison,
  metrics = c("effective_sample_size", "kernel_zero_share", "kernel_cv"))
```

## A compact review sequence

For each reported sign-restricted result:

1.  Inspect
    [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md)
    before interpreting posterior summaries.
2.  Use
    [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md)
    to report satisfaction of the fitted restrictions.
3.  Select a most-likely-admissible IRF or CDM only when one coherent
    draw is useful for presentation or downstream calculation.
4.  Repeat the diagnostics and audit across substantive alternative
    specifications rather than comparing representative paths alone.

For general tidy extraction, probability statements, response timing,
and publication output, return to [Getting
Started](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.md).
The [function
reference](https://davidzenz.github.io/bsvarPost/reference/index.html)
documents filters, tolerances, and plotting variants.
