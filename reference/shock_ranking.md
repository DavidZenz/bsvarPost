# Rank shocks by event-window historical decomposition contributions

Rank shocks by event-window historical decomposition contributions

## Usage

``` r
shock_ranking(
  object,
  start,
  end = start,
  variables = NULL,
  models = NULL,
  ranking = c("absolute", "signed"),
  probability = 0.68,
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorHD`, or tidy historical
  decomposition table.

- start:

  First time index to include.

- end:

  Last time index to include. Defaults to `start`.

- variables:

  Optional variable filter.

- models:

  Optional model filter.

- ranking:

  One of `"absolute"` or `"signed"`.

- probability:

  Equal-tailed interval probability.

- ...:

  Additional arguments passed to
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md).
