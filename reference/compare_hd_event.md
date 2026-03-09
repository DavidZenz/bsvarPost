# Compare event-window historical decompositions across models

Compare event-window historical decompositions across models

## Usage

``` r
compare_hd_event(..., start, end = start, probability = 0.68, draws = FALSE)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- start:

  First time index to include.

- end:

  Last time index to include. Defaults to `start`.

- probability:

  Equal-tailed interval probability used in summaries.

- draws:

  If `TRUE`, return draw-level rows.
