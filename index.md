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

- New to the package: [Getting
  Started](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.md)
- Looking for the broader workflow surface: [Post-Estimation
  Workflows](https://davidzenz.github.io/bsvarPost/articles/post-estimation-workflows.md)

## Core Workflow

1.  Estimate a model with `bsvars` or `bsvarSIGNs`.
2.  Extract responses or summaries with `tidy_*()` or
    [`cdm()`](https://davidzenz.github.io/bsvarPost/reference/cdm.md).
3.  Compare specifications with `compare_*()`.
4.  Audit hypotheses and restrictions.
5.  Move results into publication-oriented tables and plots.

## Main Feature Families

### Responses and extraction

- [`cdm()`](https://davidzenz.github.io/bsvarPost/reference/cdm.md)
- [`tidy_irf()`](https://davidzenz.github.io/bsvarPost/reference/tidy_irf.md),
  [`tidy_cdm()`](https://davidzenz.github.io/bsvarPost/reference/tidy_cdm.md),
  [`tidy_fevd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_fevd.md),
  [`tidy_hd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd.md),
  [`tidy_forecast()`](https://davidzenz.github.io/bsvarPost/reference/tidy_forecast.md)

### Comparison

- [`compare_irf()`](https://davidzenz.github.io/bsvarPost/reference/compare_irf.md),
  [`compare_cdm()`](https://davidzenz.github.io/bsvarPost/reference/compare_cdm.md),
  [`compare_fevd()`](https://davidzenz.github.io/bsvarPost/reference/compare_fevd.md),
  [`compare_forecast()`](https://davidzenz.github.io/bsvarPost/reference/compare_forecast.md)
- comparison helpers for response-shape summaries and diagnostics

### Representative summaries and audits

- `median_target_*()`
- `most_likely_admissible_*()`
- `hypothesis_*()`
- [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md)
- [`magnitude_audit()`](https://davidzenz.github.io/bsvarPost/reference/magnitude_audit.md)

### Historical decomposition workflows

- [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
- [`shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/shock_ranking.md)
- [`compare_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/compare_hd_event.md)

### Publication outputs

- [`publish_bsvar_plot()`](https://davidzenz.github.io/bsvarPost/reference/publish_bsvar_plot.md)
- [`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/report_bundle.md)
- [`report_table()`](https://davidzenz.github.io/bsvarPost/reference/report_table.md)
- [`as_kable()`](https://davidzenz.github.io/bsvarPost/reference/as_kable.md),
  [`as_gt()`](https://davidzenz.github.io/bsvarPost/reference/as_gt.md),
  [`as_flextable()`](https://davidzenz.github.io/bsvarPost/reference/as_flextable.md)

## Notes

- `bsvarPost` does not estimate models itself.
- Magnitude restrictions are handled as post-estimation audits, not
  estimation-time admissibility filters.
- For sign-restricted models, `most_likely_admissible_*()` is available
  only for `PosteriorBSVARSIGN`.
