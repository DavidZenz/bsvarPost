# Plots stacked historical decomposition contributions over time

Plots posterior median structural-shock contributions as stacked areas
over time. Set `include_baseline = TRUE` to include the non-shock
`"Baseline"` component in the displayed decomposition.

## Usage

``` r
plot_hd_stacked(
  object,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  models = NULL,
  facet_scales = "free_y",
  include_observed = FALSE,
  include_baseline = FALSE,
  shock_groups = NULL,
  top_n = NULL,
  collapse_other = TRUE,
  stack = c("signed", "absolute"),
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorHD`, or a tidy table of historical
  decompositions. Plots that reconstruct the observed series require a
  posterior model; when a table is supplied, cumulative event plots
  require draw-level input.

- probability:

  Probability mass of the equal-tailed credible interval computed when
  `object` is not already a summary table.

- variables:

  Variables whose historical decompositions are included.

- shocks:

  Structural shocks whose contributions are included.

- models:

  Model specifications to include.

- facet_scales:

  Facet scales passed to `ggplot2`.

- include_observed:

  If `TRUE`, include the observed series for plot types that compare
  decomposition totals against the realised path.

- include_baseline:

  If `TRUE`, include the non-shock baseline component when building a
  full decomposition.

- shock_groups:

  Optional named character vector mapping shock names to display groups.

- top_n:

  Optional number of largest contributors to retain within each
  model-variable panel.

- collapse_other:

  If `TRUE`, contributors outside `top_n` (or unmapped shocks under
  `shock_groups`) are collapsed into `"Other"`.

- stack:

  One of `"signed"` or `"absolute"` for stacked plots.

- model:

  Model label used when converting posterior objects to
  posterior-summary tables.

- ...:

  Additional arguments passed to
  [`tidy_hd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd.md)
  or
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
  when conversion is required.
