# Tidy posterior impulse responses

Tidy posterior impulse responses

## Usage

``` r
tidy_irf(object, ...)

# S3 method for class 'PosteriorBSVAR'
tidy_irf(
  object,
  horizon = 10,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
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
