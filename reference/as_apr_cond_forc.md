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
  probability = 0.9,
  center = c("median", "mean"),
  origin = NULL,
  frequency = c("quarter", "month", "year", "day"),
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
as_apr_cond_forc(
  object,
  horizon = NULL,
  probability = 0.9,
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

## Value

A data frame with columns `hor`, `variable`, `lower`, `center`, and
`upper`, suitable for use with APRScenario conditioning workflows.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

apr_forc <- as_apr_cond_forc(post, horizon = 3)
head(apr_forc)
#>   hor  variable      lower    center     upper  model
#> 1   1 variable1  -9.082878 -8.941584 -8.875381 model1
#> 2   2 variable1  -9.247464 -8.865970 -8.432210 model1
#> 3   3 variable1 -10.528405 -8.887696 -8.639741 model1
#> 4   1 variable2  -9.842239 -9.824889 -9.793765 model1
#> 5   2 variable2 -16.175162 -9.817265 -9.791415 model1
#> 6   3 variable2 -26.722178 -9.804719 -9.736834 model1
```
