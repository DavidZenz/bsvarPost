# Tidy forecasts

Tidy forecasts

## Usage

``` r
tidy_forecast(object, ...)

# Default S3 method
tidy_forecast(object, ...)
```

## Arguments

- object:

  A posterior model object or posterior IRF array.

- ...:

  Additional arguments passed to computation methods.

## Value

A `bsvar_post_tbl` (tibble subclass) with columns `model`,
`object_type`, `variable`, `shock`, `horizon`, `mean`, `median`, `sd`,
`lower`, and `upper`. When `draws = TRUE`, columns `draw` and `value`
replace the summary statistics.

## Examples

``` r
# Small posterior (S = 5 draws)
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

# Tidy forecasts
result <- tidy_forecast(post, horizon = 3)
head(result)
#> # A tibble: 6 × 9
#>   model  object_type variable  horizon  mean median     sd  lower upper
#>   <chr>  <chr>       <chr>     <chr>   <dbl>  <dbl>  <dbl>  <dbl> <dbl>
#> 1 model1 forecast    variable1 1       -8.92  -8.92 0.0120  -8.92 -8.90
#> 2 model1 forecast    variable1 2       -8.91  -8.91 0.0318  -8.94 -8.87
#> 3 model1 forecast    variable1 3       -8.94  -8.91 0.0703  -9.03 -8.87
#> 4 model1 forecast    variable2 1       -9.74  -9.76 0.206   -9.93 -9.47
#> 5 model1 forecast    variable2 2       -9.69  -9.63 0.371  -10.1  -9.26
#> 6 model1 forecast    variable2 3       -9.70  -9.57 0.761  -10.6  -8.95
```
