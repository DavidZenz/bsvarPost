# Plot event-window historical decomposition summaries

Plot event-window historical decomposition summaries

## Usage

``` r
plot_hd_event(
  object,
  start = NULL,
  end = start,
  probability = 0.9,
  draws = FALSE,
  variables = NULL,
  shocks = NULL,
  models = NULL,
  facet_scales = "free_y",
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorHD`, or tidy HD event table.

- start:

  First time index to include when `object` is not already an HD event
  table.

- end:

  Last time index to include. Defaults to `start`.

- probability:

  Equal-tailed interval probability.

- draws:

  If `TRUE`, plot draw-level event contributions.

- variables:

  Optional variable filter.

- shocks:

  Optional shock filter.

- models:

  Optional model filter.

- facet_scales:

  Facet scales passed to `ggplot2`.

- ...:

  Additional arguments passed to
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md).

## Value

A `ggplot` object.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

p <- plot_hd_event(post, start = "1948.25", end = "1948.5")
```
