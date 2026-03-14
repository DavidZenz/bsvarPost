# Compare forecasts across models

Compare forecasts across models

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

  Interval probability.

- draws:

  If `TRUE`, return draw-level rows.

## Value

A `bsvar_post_tbl` combining results across models, with a `model`
column identifying each input.

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
#>   model object_type variable  horizon  mean median     sd lower upper
#>   <chr> <chr>       <chr>     <chr>   <dbl>  <dbl>  <dbl> <dbl> <dbl>
#> 1 m1    forecast    variable1 1       -8.90  -8.91 0.0437 -8.94 -8.85
#> 2 m1    forecast    variable1 2       -8.86  -8.86 0.0242 -8.89 -8.83
#> 3 m1    forecast    variable1 3       -8.82  -8.83 0.0409 -8.86 -8.77
#> 4 m1    forecast    variable2 1       -9.73  -9.77 0.0902 -9.82 -9.63
#> 5 m1    forecast    variable2 2       -9.74  -9.80 0.133  -9.84 -9.56
#> 6 m1    forecast    variable2 3       -9.73  -9.78 0.214  -9.92 -9.45
```
