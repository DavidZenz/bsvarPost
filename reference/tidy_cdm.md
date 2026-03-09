# Tidy cumulative dynamic multipliers

Tidy cumulative dynamic multipliers

## Usage

``` r
tidy_cdm(object, ...)

# S3 method for class 'PosteriorBSVAR'
tidy_cdm(
  object,
  horizon = 10,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
```

## Arguments

- object:

  A posterior model object or posterior IRF array.

- ...:

  Additional arguments passed to computation methods.

- horizon:

  Forecast horizon when `object` is a posterior model object.

- probability:

  Equal-tailed interval probability.

- draws:

  If `TRUE`, return draw-level rows.

- model:

  Optional model identifier.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.
