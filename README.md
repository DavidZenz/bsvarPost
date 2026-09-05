<!-- generated-by: gsd-doc-writer -->
# bsvarPost

`bsvarPost` provides post-estimation methods for posterior objects from
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs). It computes
cumulative effects, tabular posterior summaries, comparisons across model
specifications, posterior probabilities, representative draws, event-specific
historical decompositions, and diagnostics for sign-restricted models.

The package is intended for analyses **after model estimation**. Use the parent
packages to specify and estimate a BSVAR, and `bsvarPost` to summarise and
evaluate the resulting posterior distribution.

## What question are you trying to answer?

| Research question | Function(s) |
|---|---|
| How can posterior impulse responses be represented in tabular form? | `tidy_irf()` |
| What is the cumulative response through a chosen horizon? | `cdm()` |
| Are posterior conclusions robust across model specifications? | `compare_irf()` or `compare_cdm()` |
| What is the posterior probability of an economically meaningful hypothesis? | `hypothesis_irf()` or `hypothesis_cdm()` |
| Does a hypothesis hold jointly, or over an entire response path? | `joint_hypothesis_irf()` or `simultaneous_irf()` |
| Which posterior draw provides a coherent representative response? | `median_target_irf()` |
| When does an impulse response peak, persist, or decay? | `peak_response()` and the timing summaries |
| Which structural shocks account for a particular historical episode? | `tidy_hd_event()` and `shock_ranking()` |
| How well do posterior draws satisfy identifying restrictions? | `restriction_audit()` and `acceptance_diagnostics()` |

The examples use one question throughout: **how does a government-spending
shock affect cumulative US GDP?**

## Installation

Install the two modelling packages first, then install `bsvarPost` from GitHub:

```r
install.packages(c("bsvars", "bsvarSIGNs", "remotes"))
remotes::install_github("DavidZenz/bsvarPost", build_vignettes = TRUE)
```

## Basic posterior analysis

### 1. Obtain a posterior distribution

If a posterior distribution from `bsvars` or `bsvarSIGNs` is already available,
assign it to `post` and skip this step. The following minimal estimation only
provides the posterior object used below; model specification and estimation
are documented by
[`bsvars`](https://bsvars.org/bsvars/).

```r
library(bsvars)
library(bsvarPost)

data(us_fiscal_lsuw)
set.seed(123)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 1e3, thin = 1, show_progress = FALSE)
```

### 2. Summarise an impulse response

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

### 3. Compute cumulative dynamic multipliers

`cdm()` computes cumulative dynamic multipliers from the posterior distributions
produced by the parent packages. It returns posterior draws, so cumulative
uncertainty is evaluated draw by draw rather than by summing marginal posterior
quantiles.

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

### Is the conclusion robust to specification choices?

Given a second estimated posterior distribution, named arguments identify the
model specifications in the combined posterior summary:

```r
comparison <- compare_cdm(baseline = post, alternative = post_alt,
                          horizon = 20)
ggplot2::autoplot(comparison)
```

Related functions compare impulse responses, forecast error variance
decompositions, forecasts, historical episodes, response timing, and identifying
restrictions. The
[Inference and Comparison article](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html)
describes how to select a comparison that corresponds to the research
hypothesis.

![Posterior impulse responses under two model
specifications](vignettes/figures/compare-irf-showcase.png)

### How strong is the posterior evidence?

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

### Which single draw should represent the posterior?

Quantiles computed separately at each horizon need not correspond to a single
admissible posterior draw. `median_target_irf()` and `median_target_cdm()` select
a representative draw whose response path is coherent across horizons.
`peak_response()`, `duration_response()`, `half_life_response()`, and
`time_to_threshold()` summarise the magnitude and timing of the resulting
responses.

![A representative posterior draw compared with the pointwise posterior
summary](vignettes/figures/representative-showcase.png)

### What drove a historical episode?

`tidy_hd_event()` summarises structural-shock contributions over a selected
period. `shock_ranking()` ranks shocks by their contributions, and
`compare_hd_event()` compares the same period across model specifications. The
[Historical-Decomposition Analysis article](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.html)
develops these analyses without repeating the construction of a historical
decomposition.

![Structural-shock contributions to GDP over the full
sample](vignettes/figures/hd-overlay-showcase.png)

### What changes for sign-restricted models?

For a `PosteriorBSVARSIGN`, `most_likely_admissible_irf()` and
`most_likely_admissible_cdm()` select representative draws among those that
satisfy the identifying restrictions. `restriction_audit()` evaluates those
restrictions, while `acceptance_diagnostics()` reports the retained posterior
sample and the support for admissible draws. See
[Analysis of Sign-Restricted Models](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.html).

![Posterior-sample and admissibility diagnostics for a sign-restricted
model](vignettes/figures/diagnostics-showcase.png)

## From results to a figure or table

Tabular posterior summaries can be visualised directly with
`ggplot2::autoplot()`. `report_bundle()` returns a plot, compact table, and
caption based on the same posterior results:

```r
result <- compare_cdm(baseline = post, alternative = post_alt, horizon = 20)
publication <- report_bundle(result,
  caption = "Cumulative output response to a government-spending shock",
  preset = "compact", digits = 3)

publication$plot
publication$table
```

Use `publish_bsvar_plot()` to apply the package's graphical style to a plot.
Additional output formats and integrations are documented in the function
reference.

## Where next?

- [Post-estimation Analysis with bsvarPost](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.html)
  develops the fiscal example from posterior estimation to an interpretable
  cumulative response.
- [Inference and Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html)
  considers sensitivity across model specifications and posterior hypotheses.
- [Historical-Decomposition Analysis](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.html)
  examines structural-shock contributions during selected historical episodes.
- [Analysis of Sign-Restricted Models](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.html)
  presents representative admissible draws, restriction evaluation, and
  acceptance diagnostics.
- [Function reference](https://davidzenz.github.io/bsvarPost/reference/)
  documents all functions and optional integrations.

## License

`bsvarPost` is licensed under GPL (>= 3).
