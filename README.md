<!-- generated-by: gsd-doc-writer -->
# bsvarPost

`bsvarPost` turns posterior objects from
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs) into focused
post-estimation answers: cumulative effects, tidy results, model comparisons,
posterior statements, coherent representative draws, event studies, diagnostics,
and publication-ready outputs.

It deliberately starts **after model estimation**. Use the parent packages to
specify, estimate, and inspect a BSVAR; use `bsvarPost` when you want to ask
questions of its posterior.

## What question are you trying to answer?

| Research question | Start here |
|---|---|
| How do I put posterior results into a tidy workflow? | `tidy_irf()` |
| What is the cumulative response through a chosen horizon? | `cdm()` |
| Are conclusions robust across specifications? | `compare_irf()` or `compare_cdm()` |
| How probable is an economically meaningful claim? | `hypothesis_irf()` or `hypothesis_cdm()` |
| Does a claim hold jointly, or across a whole response path? | `joint_hypothesis_irf()` or `simultaneous_irf()` |
| Which posterior draw gives a coherent summary? | `median_target_irf()` |
| When does a response peak, persist, or decay? | `peak_response()` and the timing summaries |
| Which shocks explain a particular historical episode? | `tidy_hd_event()` and `shock_ranking()` |
| Is a sign-restricted posterior well supported? | `restriction_audit()` and `acceptance_diagnostics()` |

The examples use one question throughout: **how does a government-spending
shock affect cumulative US GDP?**

## Installation

Install the two modelling packages first, then install `bsvarPost` from GitHub:

```r
install.packages(c("bsvars", "bsvarSIGNs", "remotes"))
remotes::install_github("DavidZenz/bsvarPost", build_vignettes = TRUE)
```

## The shortest useful path

### 1. Start with a posterior

If you already have a posterior from `bsvars` or `bsvarSIGNs`, call it `post`
and skip this step. This minimal fit only establishes the object used below;
model specification and estimation are documented by
[`bsvars`](https://bsvars.org/bsvars/).

```r
library(bsvars)
library(bsvarPost)

data(us_fiscal_lsuw)
set.seed(123)
spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 1e3, thin = 1, show_progress = FALSE)
```

### 2. Extract one result tidily

`tidy_irf()` converts posterior draws into one row per model, response variable,
shock, and horizon, with posterior summaries and credible intervals.

```r
irf_tbl <- tidy_irf(post, horizon = 20, probability = 0.90)
subset(irf_tbl, variable == "gdp" & shock == "gs" &
                  horizon %in% c(0, 4, 8, 20))
```

This is the canonical extraction pattern. The same shape extends to cumulative
dynamic multipliers, FEVDs, historical decompositions, forecasts, and shocks via
the corresponding `tidy_*()` function. Set `draws = TRUE` only when an analysis
needs draw-level output.

### 3. Ask the cumulative question

`cdm()` adds cumulative dynamic multipliers to the parent packages' standard
posterior outputs. It returns posterior draws, so uncertainty is accumulated
draw by draw rather than by summing reported quantiles.

```r
multiplier <- cdm(post, horizon = 20)
multiplier_tbl <- tidy_cdm(multiplier)
gdp_multiplier <- subset(multiplier_tbl, variable == "gdp" & shock == "gs")
ggplot2::autoplot(gdp_multiplier)
```

When the economic question calls for shock-size normalization, use
`scale_by = "shock_sd"`; otherwise the default preserves the model's original
shock scale.

## Go beyond one posterior summary

### Is the conclusion robust to specification choices?

Given a second already-fitted posterior, named arguments become readable model
labels in a combined tidy result:

```r
comparison <- compare_cdm(baseline = post, alternative = post_alt,
                          horizon = 20)
ggplot2::autoplot(comparison)
```

The same pattern applies to IRFs, FEVDs, forecasts, historical events, response
timing, and sign restrictions. The
[Inference and Comparison article](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html)
shows how to choose the comparison that matches the research claim.

### How strong is the posterior evidence?

Ask the question directly instead of inferring it from overlapping pointwise
intervals:

```r
hypothesis_cdm(post, variables = "gdp", shocks = "gs", horizon = 8,
               relation = ">", value = 0)

joint_hypothesis_cdm(post, variable = "gdp", shock = "gs", horizon = 0:8,
                     relation = ">", value = 0)
```

Use `magnitude_audit()` for economically relevant thresholds and
`simultaneous_irf()` or `simultaneous_cdm()` when uncertainty must cover a whole
selected path. See [Inference and Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html)
for pointwise, joint, magnitude, and simultaneous statements.

### Which single draw should represent the posterior?

Quantiles taken separately at every horizon need not correspond to any one
admissible model draw. `median_target_irf()` and `median_target_cdm()` select a
coherent representative draw. `peak_response()`, `duration_response()`,
`half_life_response()`, and `time_to_threshold()` then summarise the shape and
timing of responses without requiring manual draw-level calculations.

### What drove a historical episode?

Build on the parent package's historical decomposition with `tidy_hd_event()`:
aggregate a chosen event window, rank shocks with `shock_ranking()`, and compare
the same window across specifications with `compare_hd_event()`. The
[Historical-Decomposition Events article](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.html)
develops that workflow without repeating basic HD construction.

### What changes for sign-restricted models?

For a `PosteriorBSVARSIGN`, use `most_likely_admissible_irf()` or
`most_likely_admissible_cdm()` for representative admissible draws. Then use
`restriction_audit()` to check identifying restrictions and
`acceptance_diagnostics()` to inspect the effective stored sample and sparse
admissibility support. See [Sign-Restricted Workflows](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.html).

## From results to a figure or table

Tidy outputs work directly with `ggplot2::autoplot()`. For a consistent final
artifact, bundle the plot, compact table, and caption once:

```r
result <- compare_cdm(baseline = post, alternative = post_alt, horizon = 20)
publication <- report_bundle(result,
  caption = "Cumulative output response to a government-spending shock",
  preset = "compact", digits = 3)

publication$plot
publication$table
```

Use `publish_bsvar_plot()` when only a styled plot is needed. Reference pages
cover optional output backends and integration bridges without placing them on
the main workflow.

## Where next?

- [Getting Started](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.html)
  develops the fiscal example from posterior to interpretable result.
- [Inference and Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html)
  covers specification sensitivity and posterior claims.
- [Historical-Decomposition Events](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.html)
  turns HD draws into focused episode analysis.
- [Sign-Restricted Workflows](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.html)
  covers admissible summaries, audits, and diagnostics.
- [Function reference](https://davidzenz.github.io/bsvarPost/reference/)
  is the discoverability layer for variants and optional integrations.

## License

`bsvarPost` is licensed under GPL (>= 3).
