# Plot observed, fitted, and selected decomposition totals

Plot observed, fitted, and selected decomposition totals

## Usage

``` r
plot_hd_total(
  object,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  models = NULL,
  facet_scales = "free_y",
  include_observed = TRUE,
  include_residual = TRUE,
  shock_groups = NULL,
  top_n = NULL,
  collapse_other = TRUE,
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

  If `TRUE`, overlay the observed series when it can be recovered from a
  posterior model object.

- include_residual:

  If `TRUE`, include a residual/unexplained component whenever the
  observed path differs materially from the fitted contribution sum.

- shock_groups:

  Optional named character vector mapping shock names to display groups.

- top_n:

  Optional number of largest contributors to retain within each
  model-variable panel.

- collapse_other:

  If `TRUE`, contributors outside `top_n` (or unmapped shocks under
  `shock_groups`) are collapsed into `"Other"`.

- ...:

  Additional arguments passed to
  [`tidy_hd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd.md)
  or
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
  when conversion is required.
