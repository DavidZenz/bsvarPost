# Compare posterior forecasts across model specifications

Compare posterior forecasts across model specifications

## Usage

``` r
compare_forecast(..., horizon = NULL, probability = 0.9, draws = FALSE)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- horizon:

  Forecast horizon. If `NULL` (default), resolves to 20 periods.

- probability:

  Probability mass of the equal-tailed credible interval.

- draws:

  If `TRUE`, report individual posterior draws rather than posterior
  summaries.

## Value

A `bsvar_post_tbl` combining results across models, with a `model`
column identifying each model specification.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_forecast(m1 = post1, m2 = post2, horizon = 3)
head(comp)
#> # A tibble: 6 × 9
#>   model object_type variable  horizon   mean median    sd lower upper
#>   <chr> <chr>       <chr>     <chr>    <dbl>  <dbl> <dbl> <dbl> <dbl>
#> 1 m1    forecast    variable1 1        -9.25  -9.09 0.607 -10.1 -8.81
#> 2 m1    forecast    variable1 2        -9.92  -8.98 2.47  -13.3 -8.56
#> 3 m1    forecast    variable1 3       -10.9   -9.16 4.10  -16.5 -8.92
#> 4 m1    forecast    variable2 1        -9.76  -9.83 0.256 -10.1 -9.51
#> 5 m1    forecast    variable2 2        -9.72  -9.68 0.449 -10.2 -9.20
#> 6 m1    forecast    variable2 3       -10.5   -9.53 2.36  -13.7 -9.15
```
