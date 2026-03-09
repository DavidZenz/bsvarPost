# Compare forecasts across models

Compare forecasts across models

## Usage

``` r
compare_forecast(..., horizon = 10, probability = 0.68, draws = FALSE)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- horizon:

  Forecast horizon.

- probability:

  Interval probability.

- draws:

  If `TRUE`, return draw-level rows.
