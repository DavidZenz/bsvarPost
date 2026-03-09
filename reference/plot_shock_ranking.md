# Plot ranked event-window shock contributions

Plot ranked event-window shock contributions

## Usage

``` r
plot_shock_ranking(
  object,
  start = NULL,
  end = start,
  variables = NULL,
  models = NULL,
  ranking = c("absolute", "signed"),
  top_n = NULL,
  probability = 0.68,
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorHD`, or tidy shock-ranking table.

- start:

  First time index to include when `object` is not already a shock
  ranking table.

- end:

  Last time index to include. Defaults to `start`.

- variables:

  Optional variable filter.

- models:

  Optional model filter.

- ranking:

  One of `"absolute"` or `"signed"`.

- top_n:

  Optional number of top-ranked shocks to keep per model-variable panel.

- probability:

  Equal-tailed interval probability.

- ...:

  Additional arguments passed to
  [`shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/shock_ranking.md).
