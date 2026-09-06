# Plots cumulative event-window contribution paths

Plots the cumulative posterior contributions of structural shocks
throughout a selected historical period, including equal-tailed credible
intervals.

## Usage

``` r
plot_hd_event_cumulative(
  object,
  start,
  end = start,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  models = NULL,
  shock_groups = NULL,
  top_n = NULL,
  collapse_other = TRUE,
  facet_scales = "free_y",
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

- start, end:

  Event-window start and end indexes for event-specific plots.

- probability:

  Probability mass of the equal-tailed credible interval computed when
  `object` is not already a summary table.

- variables:

  Variables whose historical decompositions are included.

- shocks:

  Structural shocks whose contributions are included.

- models:

  Model specifications to include.

- shock_groups:

  Optional named character vector mapping shock names to display groups.

- top_n:

  Optional number of largest contributors to retain within each
  model-variable panel.

- collapse_other:

  If `TRUE`, contributors outside `top_n` (or unmapped shocks under
  `shock_groups`) are collapsed into `"Other"`.

- facet_scales:

  Facet scales passed to `ggplot2`.

- model:

  Model label used when converting posterior objects to
  posterior-summary tables.

- ...:

  Additional arguments passed to
  [`tidy_hd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd.md)
  or
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
  when conversion is required.
