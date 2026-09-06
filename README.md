<!-- generated-by: gsd-doc-writer -->
# bsvarPost

An **R** package for post-estimation analysis of Bayesian Structural Vector
Autoregressions

`bsvarPost` computes cumulative effects and tabular posterior summaries from
posterior objects produced by
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs). It compares model
specifications, evaluates posterior hypotheses, selects representative draws,
analyses event-specific historical decompositions, and reports diagnostics for
sign-restricted models.

The package analyses posterior distributions **after model estimation**.
`bsvars` and `bsvarSIGNs` specify and estimate BSVAR models, while `bsvarPost`
summarises, compares, and evaluates the resulting posterior distributions.

## Features

| Analysis | Function(s) |
|---|---|
| Tabular posterior summaries of impulse responses | `tidy_irf()` |
| Cumulative responses through a selected horizon | `cdm()` |
| Comparison of posterior conclusions across model specifications | `compare_irf()` or `compare_cdm()` |
| Posterior probabilities of economically meaningful hypotheses | `hypothesis_irf()` or `hypothesis_cdm()` |
| Joint hypotheses and simultaneous inference over response paths | `joint_hypothesis_irf()` or `simultaneous_irf()` |
| Representative posterior response draws | `median_target_irf()` |
| Peak, persistence, and decay of impulse responses | `peak_response()` and the timing summaries |
| Structural-shock contributions during historical episodes | `tidy_hd_event()` and `shock_ranking()` |
| Evaluation of identifying restrictions and admissible draws | `restriction_audit()` and `acceptance_diagnostics()` |

The examples analyse the cumulative response of US GDP to a
government-spending shock.

## Installation

Install the two modelling packages first, then install `bsvarPost` from GitHub:

```r
install.packages(c("bsvars", "bsvarSIGNs", "remotes"))
remotes::install_github("DavidZenz/bsvarPost", build_vignettes = TRUE)
```

## Posterior summaries and cumulative responses

### Obtain a posterior distribution

If a posterior distribution from `bsvars` or `bsvarSIGNs` is already
available, assign it to `post`. The following minimal estimation produces the
posterior object used below. Model specification and estimation are documented
by [`bsvars`](https://bsvars.org/bsvars/).

```r
library(bsvars)
library(bsvarPost)

data(us_fiscal_lsuw)
set.seed(123)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 1e3, thin = 1, show_progress = FALSE)
```

### Summarise impulse responses

`tidy_irf()` computes posterior summaries and credible intervals for each model,
response variable, structural shock, and horizon, and returns them in tabular
form.

```r
irf_tbl <- tidy_irf(post, horizon = 20, probability = 0.90)
subset(irf_tbl, variable == "gdp" & shock == "gs" &
                  horizon %in% c(0, 4, 8, 20))
```

The corresponding `tidy_*()` functions provide the same tabular representation
for cumulative dynamic multipliers, forecast error variance decompositions,
historical decompositions, forecasts, and structural shocks. Set `draws = TRUE`
when posterior draw-level output is required.

### Compute cumulative dynamic multipliers

`cdm()` computes cumulative dynamic multipliers from posterior distributions
produced by `bsvars` and `bsvarSIGNs`. It returns posterior draws and thereby
evaluates cumulative uncertainty draw by draw rather than by summing marginal
posterior quantiles.

```r
multiplier <- cdm(post, horizon = 20)
multiplier_tbl <- tidy_cdm(multiplier)
gdp_multiplier <- subset(multiplier_tbl, variable == "gdp" & shock == "gs")
ggplot2::autoplot(gdp_multiplier)
```

![Posterior cumulative dynamic responses with pointwise credible
bands](vignettes/figures/cdm-showcase.png)

For cumulative responses normalised by the sample standard deviation of the
corresponding observed variable, use `scale_by = "shock_sd"`. The default
retains the shock scale of the estimated model.

## Posterior inference and model comparison

### Compare model specifications

Named arguments identify model specifications in posterior comparisons. Here,
`post_alt` denotes posterior draws from an alternative model specification:

```r
comparison <- compare_cdm(baseline = post, alternative = post_alt,
                          horizon = 20)
ggplot2::autoplot(comparison)
```

The comparison functions also analyse impulse responses, forecast error variance
decompositions, forecasts, historical episodes, response timing, and identifying
restrictions. The
[Inference and Comparison article](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html)
describes comparisons corresponding to different research hypotheses.

![Posterior impulse responses under two model
specifications](vignettes/figures/compare-irf-showcase.png)

### Evaluate posterior hypotheses

Posterior probabilities evaluate hypotheses directly and should not be inferred
from whether pointwise credible intervals overlap:

```r
hypothesis_cdm(post, variables = "gdp", shocks = "gs", horizon = 8,
               relation = ">", value = 0)

joint_hypothesis_cdm(post, variable = "gdp", shock = "gs", horizon = 0:8,
                     relation = ">", value = 0)
```

`magnitude_audit()` evaluates economically relevant thresholds.
`simultaneous_irf()` and `simultaneous_cdm()` compute credible bands with
simultaneous coverage over a selected response path. See
[Inference and Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html)
for pointwise and joint hypotheses, magnitude thresholds, and simultaneous
credible bands.

### Select representative posterior draws

Quantiles computed separately at each horizon need not correspond to a single
admissible posterior draw. `median_target_irf()` and `median_target_cdm()` select
a representative draw whose response path is coherent across horizons.
`peak_response()`, `duration_response()`, `half_life_response()`, and
`time_to_threshold()` summarise the magnitude and timing of the resulting
responses.

![A representative posterior draw compared with the pointwise posterior
summary](vignettes/figures/representative-showcase.png)

### Analyse historical decompositions

`tidy_hd_event()` summarises structural-shock contributions over a selected
period. `shock_ranking()` ranks these contributions, and `compare_hd_event()`
compares the same period across model specifications. The
[Historical Decompositions article](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.html)
develops these analyses without repeating the construction of a historical
decomposition.

![Structural-shock contributions to GDP over the full
sample](vignettes/figures/hd-overlay-showcase.png)

### Analyse sign-restricted models

For a `PosteriorBSVARSIGN`, `most_likely_admissible_irf()` and
`most_likely_admissible_cdm()` select representative draws among those that
satisfy the identifying restrictions. `restriction_audit()` evaluates those
restrictions, while `acceptance_diagnostics()` reports the retained posterior
sample and the support for admissible draws. See
[Analysis of Sign-Restricted Models](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.html).

![Posterior-sample and admissibility diagnostics for a sign-restricted
model](vignettes/figures/diagnostics-showcase.png)

## Figures and tables

`ggplot2::autoplot()` plots tabular posterior summaries directly.
`report_bundle()` returns a plot, compact table, and caption based on the same
posterior results:

```r
result <- compare_cdm(baseline = post, alternative = post_alt, horizon = 20)
publication <- report_bundle(result,
  caption = "Cumulative output response to a government-spending shock",
  preset = "compact", digits = 3)

publication$plot
publication$table
```

`publish_bsvar_plot()` applies the package's graphical style to a plot. The
function reference documents additional output formats and interfaces with
other **R** packages.

## Documentation

- [Post-estimation Analysis with bsvarPost](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.html)
  develops the fiscal example from posterior estimation to an interpretable
  cumulative response.
- [Inference and Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html)
  considers sensitivity across model specifications and posterior hypotheses.
- [Historical Decompositions](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.html)
  examines structural-shock contributions during selected historical episodes.
- [Analysis of Sign-Restricted Models](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.html)
  presents representative admissible draws, restriction evaluation, and
  acceptance diagnostics.
- [Function reference](https://davidzenz.github.io/bsvarPost/reference/)
  documents all functions and optional integrations.

## License

`bsvarPost` is licensed under GPL (>= 3).
