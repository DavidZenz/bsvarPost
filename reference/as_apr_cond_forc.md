# Express posterior forecasts in APRScenario format

Express posterior forecasts in APRScenario format

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

  Posterior location summary represented by APRScenario's `center`
  column.

- origin:

  Optional `Date` origin for turning forecast horizons into APR style
  `hor` dates.

- frequency:

  Step size used with `origin`. One of `"quarter"`, `"month"`, `"year"`,
  or `"day"`.

- probability:

  Probability mass of the equal-tailed credible interval.

- model:

  Label identifying the model specification.

- horizon:

  Forecast horizon when `object` is a posterior model object.

## Value

A data frame with columns `hor`, `variable`, `lower`, `center`, and
`upper`, suitable for use with conditional forecast analysis with
APRScenario.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

apr_forc <- as_apr_cond_forc(post, horizon = 3)
head(apr_forc)
#>   hor  variable      lower    center     upper  model
#> 1   1 variable1  -8.996956 -8.868245 -8.828637 model1
#> 2   2 variable1  -9.283976 -8.837319 -8.728452 model1
#> 3   3 variable1 -10.456010 -8.788829 -8.731512 model1
#> 4   1 variable2  -9.874547 -9.779793 -8.668058 model1
#> 5   2 variable2  -9.968457 -9.723177 -8.843310 model1
#> 6   3 variable2 -10.269563 -9.857588 -9.284399 model1
```
