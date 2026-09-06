An **R** package for posterior analysis of Bayesian Structural Vector
Autoregressions estimated with
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs).

Provides posterior summaries and inference for empirical analyses based
on impulse responses, cumulative dynamic multipliers, forecast error
variance decompositions, historical decompositions, forecasts, and
structural shocks. The package also compares model specifications,
evaluates identifying restrictions, and reports posterior results in
figures and tables.

Use `bsvars` or `bsvarSIGNs` to specify and estimate the Bayesian VAR.
Use `bsvarPost` to analyse its posterior distribution.

## Posterior summaries of structural quantities

Summarise impulse responses from an existing `bsvars` or `bsvarSIGNs`
posterior with
[`tidy_irf()`](https://davidzenz.github.io/bsvarPost/reference/tidy_irf.md):

``` r

library(bsvarPost)

responses <- tidy_irf(posterior, horizon = 12, probability = 0.90)
head(responses)
```

Represent cumulative dynamic multipliers, forecast error variance
decompositions, historical decompositions, forecasts, and structural
shocks in the same tabular form. Filter, visualise, join, or report
these posterior quantities with standard R functions.

Compute posterior cumulative effects explicitly with
[`cdm()`](https://davidzenz.github.io/bsvarPost/reference/cdm.md):

``` r

multipliers <- cdm(posterior, horizon = 12)
tidy_cdm(multipliers)
```

See [Post-estimation Analysis with
bsvarPost](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.md)
for a reproducible introduction to posterior summaries, cumulative
effects, and their graphical presentation.

## Features

### Comparison of model specifications

Compare impulse responses, cumulative effects, decompositions,
forecasts, response-timing summaries, and diagnostics across named
posterior objects in one table.

[Inference and
Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.md)
shows how to compare specifications, compute posterior probabilities and
magnitudes, evaluate joint hypotheses, construct simultaneous credible
bands, and select representative posterior draws. It also describes
response characteristics such as peaks, duration, half-life, and time to
a threshold.

### Historical decompositions and shock contributions

Summarise the posterior contribution of each structural shock over a
selected event window. Rank these contributions and compare the same
historical episode across model specifications.

[Historical
Decompositions](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.md)
describes event-specific analysis with
[`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md),
[`shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/shock_ranking.md),
and graphical summaries of shock contributions.

### Analysis of sign-restricted models

Select an admissible draw that represents the posterior distribution,
verify whether retained draws satisfy the imposed restrictions, and
examine whether admissibility weights indicate weak or sparse posterior
support.

[Analysis of Sign-Restricted
Models](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.md)
describes `most_likely_admissible_*()`,
[`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md),
[`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md),
and the corresponding comparison and plotting methods.

### Figures and tables

Plot tidy posterior summaries directly with `ggplot2` or present them
with table-generation packages. Use
[`ggplot2::autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
for a default graphical summary and the publication-graphics functions
for consistent styling and annotations. Convert the same results into
labelled tables so that figures and tables report identical posterior
quantities.

## Integration with bsvars and bsvarSIGNs

Use `bsvars` or `bsvarSIGNs` to specify, estimate, and inspect the
underlying model. Use `bsvarPost` to:

- represent posterior quantities as tidy data sets;
- compute cumulative effects, compare specifications, evaluate posterior
  hypotheses, or summarise response timing;
- analyse structural-shock contributions during a historical episode or
  assess sign restrictions; or
- report a selected posterior result in a figure or table.

Consult the [reference
index](https://davidzenz.github.io/bsvarPost/reference/index.md) for
definitions, arguments, and return values. The articles above introduce
the principal forms of posterior analysis.
