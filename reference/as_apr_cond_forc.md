# Convert tidy forecasts to APRScenario format

Convert tidy forecasts to APRScenario format

## Usage

``` r
as_apr_cond_forc(object, ...)

# S3 method for class 'bsvar_post_tbl'
as_apr_cond_forc(
  object,
  center = c("median", "mean"),
  origin = NULL,
  frequency = c("quarter", "month", "year", "day"),
  ...
)

# S3 method for class 'Forecasts'
as_apr_cond_forc(
  object,
  probability = 0.68,
  center = c("median", "mean"),
  origin = NULL,
  frequency = c("quarter", "month", "year", "day"),
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
as_apr_cond_forc(
  object,
  horizon = 10,
  probability = 0.68,
  center = c("median", "mean"),
  origin = NULL,
  frequency = c("quarter", "month", "year", "day"),
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object, a `Forecasts` object, or a tidy forecast
  table returned by
  [`tidy_forecast()`](https://davidzenz.github.io/bsvarPost/reference/tidy_forecast.md).

- ...:

  Additional arguments passed to
  [`tidy_forecast()`](https://davidzenz.github.io/bsvarPost/reference/tidy_forecast.md).

- center:

  Which summary column to map to APRScenario's `center` column.

- origin:

  Optional `Date` origin for turning forecast horizons into APR style
  `hor` dates.

- frequency:

  Step size used with `origin`. One of `"quarter"`, `"month"`, `"year"`,
  or `"day"`.

- probability:

  Equal-tailed interval probability.

- model:

  Optional model identifier.

- horizon:

  Forecast horizon when `object` is a posterior model object.
