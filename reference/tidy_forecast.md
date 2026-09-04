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
#>   model  object_type variable  horizon   mean median    sd  lower  upper
#>   <chr>  <chr>       <chr>     <chr>    <dbl>  <dbl> <dbl>  <dbl>  <dbl>
#> 1 model1 forecast    variable1 1        -8.70  -8.79 0.218  -8.88  -8.41
#> 2 model1 forecast    variable1 2        -8.73  -8.77 0.145  -8.86  -8.54
#> 3 model1 forecast    variable1 3        -8.50  -8.50 0.137  -8.62  -8.33
#> 4 model1 forecast    variable2 1       -10.3  -10.1  0.612 -11.0   -9.71
#> 5 model1 forecast    variable2 2       -10.2  -10.0  0.371 -10.7   -9.88
#> 6 model1 forecast    variable2 3       -10.8  -10.9  0.482 -11.3  -10.2 
```
