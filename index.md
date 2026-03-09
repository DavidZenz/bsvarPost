---
title: bsvarPost
---

`bsvarPost` is a post-estimation companion package for
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs).

It focuses on what happens after estimation:

- cumulative dynamic multipliers
- tidy extraction of posterior objects
- model comparison
- representative-model summaries
- restriction, magnitude, and hypothesis audits
- diagnostics for sign-restricted models
- historical-decomposition event workflows
- publication-oriented plotting and reporting

## Start Here

- New to the package: [Getting Started](articles/bsvarPost.html)
- Looking for the broader workflow surface: [Post-Estimation Workflows](articles/post-estimation-workflows.html)

## Core Workflow

1. Estimate a model with `bsvars` or `bsvarSIGNs`.
2. Extract responses or summaries with `tidy_*()` or `cdm()`.
3. Compare specifications with `compare_*()`.
4. Audit hypotheses and restrictions.
5. Move results into publication-oriented tables and plots.

## Main Feature Families

### Responses and extraction

- `cdm()`
- `tidy_irf()`, `tidy_cdm()`, `tidy_fevd()`, `tidy_hd()`, `tidy_forecast()`

### Comparison

- `compare_irf()`, `compare_cdm()`, `compare_fevd()`, `compare_forecast()`
- comparison helpers for response-shape summaries and diagnostics

### Representative summaries and audits

- `median_target_*()`
- `most_likely_admissible_*()`
- `hypothesis_*()`
- `restriction_audit()`
- `magnitude_audit()`

### Historical decomposition workflows

- `tidy_hd_event()`
- `shock_ranking()`
- `compare_hd_event()`

### Publication outputs

- `publish_bsvar_plot()`
- `report_bundle()`
- `report_table()`
- `as_kable()`, `as_gt()`, `as_flextable()`

## Notes

- `bsvarPost` does not estimate models itself.
- Magnitude restrictions are handled as post-estimation audits, not
  estimation-time admissibility filters.
- For sign-restricted models, `most_likely_admissible_*()` is available only
  for `PosteriorBSVARSIGN`.
