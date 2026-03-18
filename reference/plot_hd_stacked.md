# Stacked historical decomposition contributions over time

This plot shows stacked historical shock contributions over time. Set
`include_baseline = TRUE` to add the non-shock `"Baseline"` component
and obtain the full displayed decomposition.

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

  A posterior model object, `PosteriorHD`, or a tidy
  historical-decomposition table.

- probability:

  Equal-tailed interval probability used when `object` is not already a
  tidy table.

- variables:

  Optional variable filter.

- shocks:

  Optional shock filter applied before grouping.

- models:

  Optional model filter.

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

  Model label used when converting posterior objects to tidy plotting
  tables.

- ...:

  Additional arguments passed to
  [`tidy_hd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd.md)
  or
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
  when conversion is required.
