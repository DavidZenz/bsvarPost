**Ask more of your structural VAR posterior.**

`bsvarPost` begins where
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs) leave off.
Bring an estimated posterior and use it to answer research questions,
compare specifications, diagnose identifying restrictions, and prepare
results for communication.

The package does not provide another estimation workflow. It adds a
consistent post-estimation layer for the questions that arise after a
model has been fit.

## The shortest path

If you already have a `bsvars` or `bsvarSIGNs` posterior, you are ready
to start. A typical first step turns a posterior result into a compact
tidy table:

``` r

library(bsvarPost)

responses <- tidy_irf(posterior, horizon = 12, probability = 0.90)
head(responses)
```

The same tidy shape is available for cumulative dynamic multipliers,
forecast error variance decompositions, historical decompositions,
forecasts, and structural shocks. Learn the pattern once, then filter,
plot, join, or report the result with familiar tools.

For cumulative effects, compute the posterior object explicitly with
[`cdm()`](https://davidzenz.github.io/bsvarPost/reference/cdm.md):

``` r

multipliers <- cdm(posterior, horizon = 12)
tidy_cdm(multipliers)
```

Start with [Getting
Started](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.md)
for a short, reproducible walkthrough from an existing posterior to tidy
results, cumulative effects, and a publication-ready figure.

## What question are you asking?

### Do conclusions survive a different specification?

Use the comparison workflow to place results from named posterior
objects in one table. You can compare responses, cumulative effects,
decompositions, forecasts, timing summaries, and diagnostics without
manually binding model outputs.

[Inference and
Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.md)
shows how to compare specifications, state posterior probability and
magnitude questions, evaluate joint hypotheses, construct simultaneous
bands, and select coherent representative draws. It also covers useful
response-shape summaries such as peaks, duration, half-life, and time to
a threshold.

### Which shocks mattered during a particular episode?

Rather than reproducing a full historical decomposition, define an event
window and summarize the posterior contribution of each shock. Rank
shocks by their contribution and compare the same episode across models.

[Historical-Decomposition
Events](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.md)
develops this event-centred workflow with
[`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md),
[`shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/shock_ranking.md),
and focused visual summaries.

### Are sign-restricted results well supported?

Sign-restricted posteriors carry questions that do not arise in the same
way for other identification schemes: which admissible draw best
represents the posterior, whether stated restrictions hold in saved
draws, and whether the admissibility weights indicate weak or sparse
support.

[Sign-Restricted
Workflows](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.md)
brings together `most_likely_admissible_*()`,
[`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md),
[`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md),
and the corresponding comparison and plotting workflows.

### How do I turn results into a figure or table?

Tidy outputs work directly with `ggplot2` and table tools.
[`ggplot2::autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
provides a useful first view; the publication helpers add consistent
styling, annotations, and export settings. Reporting helpers convert the
same focused result into a labelled table, so analysis and presentation
stay connected.

## A small package by design

Use `bsvars` or `bsvarSIGNs` to specify, estimate, and inspect the
underlying model. Use `bsvarPost` when you need to:

- express a posterior result as a tidy, reusable data set;
- answer a cumulative, comparative, probabilistic, or timing question;
- investigate a historical episode or sign-restriction diagnostic; or
- carry a focused result into a publication-ready plot or table.

Function-level details and variants remain available in the [reference
index](https://davidzenz.github.io/bsvarPost/reference/index.md). The
articles above are the recommended route through the package.
