---
title: bsvarPost
---

**Posterior analysis for Bayesian structural VARs.**

`bsvarPost` extends posterior analysis for models estimated with
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs). Given an
estimated posterior, it computes quantities used to address empirical
questions, compare model specifications, evaluate identifying restrictions,
and report results.

The package does not estimate Bayesian VARs. It provides a consistent set of
post-estimation methods for posterior summaries and inference.

## Posterior summaries

For an existing `bsvars` or `bsvarSIGNs` posterior, `tidy_irf()` summarises
impulse responses in a compact table:

```r
library(bsvarPost)

responses <- tidy_irf(posterior, horizon = 12, probability = 0.90)
head(responses)
```

The same tabular representation is available for cumulative dynamic
multipliers, forecast error variance decompositions, historical
decompositions, forecasts, and structural shocks. These results can then be
filtered, visualised, joined, or reported with standard R functions.

For cumulative effects, compute the posterior object explicitly with
[`cdm()`](reference/cdm.html):

```r
multipliers <- cdm(posterior, horizon = 12)
tidy_cdm(multipliers)
```

See [Post-estimation Analysis with bsvarPost](articles/bsvarPost.html) for a short, reproducible
introduction to posterior summaries, cumulative effects, and a figure suitable
for publication.

## What question are you asking?

### Do conclusions survive a different specification?

The comparison functions combine results from named posterior objects in one
table. They compare impulse responses, cumulative effects, decompositions,
forecasts, response-timing summaries, and diagnostics across model
specifications.

[Inference and Comparison](articles/inference-and-comparison.html) shows how to
compare specifications, compute posterior probabilities and magnitudes,
evaluate joint hypotheses, construct simultaneous credible bands, and select
representative posterior draws. It also describes response characteristics
such as peaks, duration, half-life, and time to a threshold.

### Which shocks mattered during a particular episode?

For a selected event window, the package summarises the posterior contribution
of each structural shock. These contributions can be ranked and compared for
the same episode across model specifications.

[Historical-Decomposition Analysis](articles/historical-decomposition-events.html)
describes event-specific analysis with `tidy_hd_event()`, `shock_ranking()`,
and graphical summaries of shock contributions.

### Are sign-restricted results well supported?

Sign-restricted posteriors require additional evaluation: which admissible draw
represents the posterior distribution, whether the imposed restrictions hold
in the retained draws, and whether the admissibility weights indicate weak or
sparse posterior support.

[Analysis of Sign-Restricted Models](articles/sign-restricted-workflows.html)
describes `most_likely_admissible_*()`, `restriction_audit()`,
`acceptance_diagnostics()`, and the corresponding comparison and plotting
methods.

### How do I turn results into a figure or table?

Tidy posterior summaries work directly with `ggplot2` and table-generation
packages. `ggplot2::autoplot()` provides a default graphical summary; functions
for publication graphics add consistent styling, annotations, and export
settings. Reporting functions convert the same result into a labelled table,
so figures and tables represent the same posterior quantities.

## Scope

Use `bsvars` or `bsvarSIGNs` to specify, estimate, and inspect the underlying
model. Use `bsvarPost` when you need to:

- represent posterior quantities as tidy data sets;
- compute cumulative effects, compare specifications, evaluate posterior
  hypotheses, or summarise response timing;
- analyse structural-shock contributions during a historical episode or assess
  sign restrictions; or
- report a selected posterior result in a figure or table.

Definitions, arguments, and return values for individual functions are
documented in the [reference index](reference/index.html). The articles above
provide introductions to the main forms of posterior analysis.
