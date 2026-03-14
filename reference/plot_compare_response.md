# Plot comparison summaries for response-shape tables

Plot comparison summaries for response-shape tables

## Usage

``` r
plot_compare_response(
  object,
  measure = NULL,
  variables = NULL,
  shocks = NULL,
  models = NULL,
  facet_scales = "free_y"
)
```

## Arguments

- object:

  A comparison table returned by
  [`compare_peak_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_peak_response.md),
  [`compare_duration_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_duration_response.md),
  [`compare_half_life_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_half_life_response.md),
  or
  [`compare_time_to_threshold()`](https://davidzenz.github.io/bsvarPost/reference/compare_time_to_threshold.md).

- measure:

  Which summary measure to plot. Defaults to the main comparison metric
  implied by `object`.

- variables:

  Optional variable filter.

- shocks:

  Optional shock filter.

- models:

  Optional model filter.

- facet_scales:

  Facet scales passed to `ggplot2`.

## Value

A `ggplot` object.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_peak_response(m1 = post1, m2 = post2, horizon = 3)
p <- plot_compare_response(comp)
```
