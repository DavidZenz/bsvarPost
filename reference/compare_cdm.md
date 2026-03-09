# Compare cumulative dynamic multipliers across models

Compare cumulative dynamic multipliers across models

## Usage

``` r
compare_cdm(
  ...,
  horizon = 10,
  probability = 0.68,
  draws = FALSE,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL
)
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

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.
