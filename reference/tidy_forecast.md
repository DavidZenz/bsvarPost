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
#>   model  object_type variable  horizon   mean median     sd  lower  upper
#>   <chr>  <chr>       <chr>     <chr>    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
#> 1 model1 forecast    variable1 1        -8.92  -8.92 0.0222  -8.94  -8.89
#> 2 model1 forecast    variable1 2        -8.89  -8.89 0.0359  -8.93  -8.85
#> 3 model1 forecast    variable1 3        -8.88  -8.89 0.0418  -8.91  -8.82
#> 4 model1 forecast    variable2 1        -9.94  -9.94 0.0729 -10.0   -9.87
#> 5 model1 forecast    variable2 2       -10.0  -10.1  0.287  -10.3   -9.65
#> 6 model1 forecast    variable2 3       -10.3  -10.3  0.273  -10.6  -10.0 
```
