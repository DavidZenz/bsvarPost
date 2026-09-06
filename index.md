---
title: bsvarPost
---

An **R** package for posterior analysis of Bayesian Structural Vector
Autoregressions estimated with
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs).

Provides posterior summaries and inference for empirical analyses based on
impulse responses, cumulative dynamic multipliers, forecast error variance
decompositions, historical decompositions, forecasts, and structural shocks.
The package also compares model specifications, evaluates identifying
restrictions, and reports posterior results in figures and tables.

Use `bsvars` or `bsvarSIGNs` to specify and estimate the Bayesian VAR. Use
`bsvarPost` to analyse its posterior distribution.

## Posterior summaries of structural quantities

Summarise impulse responses from an existing `bsvars` or `bsvarSIGNs`
posterior with `tidy_irf()`:

```r
library(bsvarPost)

responses <- tidy_irf(posterior, horizon = 12, probability = 0.90)
head(responses)
```

Represent cumulative dynamic multipliers, forecast error variance
decompositions, historical decompositions, forecasts, and structural shocks
in the same tabular form. Filter, visualise, join, or report these posterior
quantities with standard R functions.

Compute posterior cumulative effects explicitly with
[`cdm()`](reference/cdm.html):

```r
multipliers <- cdm(posterior, horizon = 12)
tidy_cdm(multipliers)
```

See [Post-estimation Analysis with bsvarPost](articles/bsvarPost.html) for a
reproducible introduction to posterior summaries, cumulative effects, and
their graphical presentation.

## Features

### Comparison of model specifications

Compare impulse responses, cumulative effects, decompositions, forecasts,
response-timing summaries, and diagnostics across named posterior objects in
one table.

[Inference and Comparison](articles/inference-and-comparison.html) shows how to
compare specifications, compute posterior probabilities and magnitudes,
evaluate joint hypotheses, construct simultaneous credible bands, and select
representative posterior draws. It also describes response characteristics
such as peaks, duration, half-life, and time to a threshold.

### Historical decompositions and shock contributions

Summarise the posterior contribution of each structural shock over a selected
event window. Rank these contributions and compare the same historical episode
across model specifications.

[Historical Decompositions](articles/historical-decomposition-events.html)
describes event-specific analysis with `tidy_hd_event()`, `shock_ranking()`,
and graphical summaries of shock contributions.

### Analysis of sign-restricted models

Select an admissible draw that represents the posterior distribution, verify
whether retained draws satisfy the imposed restrictions, and examine whether
admissibility weights indicate weak or sparse posterior support.

[Analysis of Sign-Restricted Models](articles/sign-restricted-workflows.html)
describes `most_likely_admissible_*()`, `restriction_audit()`,
`acceptance_diagnostics()`, and the corresponding comparison and plotting
methods.

### Figures and tables

Plot tidy posterior summaries directly with `ggplot2` or present them with
table-generation packages. Use `ggplot2::autoplot()` for a default graphical
summary and the publication-graphics functions for consistent styling and
annotations. Convert the same results into labelled
tables so that figures and tables report identical posterior quantities.

## Integration with bsvars and bsvarSIGNs

Use `bsvars` or `bsvarSIGNs` to specify, estimate, and inspect the underlying
model. Use `bsvarPost` to:

- represent posterior quantities as tidy data sets;
- compute cumulative effects, compare specifications, evaluate posterior
  hypotheses, or summarise response timing;
- analyse structural-shock contributions during a historical episode or assess
  sign restrictions; or
- report a selected posterior result in a figure or table.

Consult the [reference index](reference/index.html) for definitions, arguments,
and return values. The articles above introduce the principal forms of
posterior analysis.
