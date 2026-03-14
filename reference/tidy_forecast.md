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
#> 1 model1 forecast    variable1 1       -8.90  -8.89 0.0517  -8.97 -8.85
#> 2 model1 forecast    variable1 2       -8.87  -8.86 0.0797  -8.97 -8.78
#> 3 model1 forecast    variable1 3       -8.81  -8.85 0.118   -8.89 -8.65
#> 4 model1 forecast    variable2 1       -9.85  -9.82 0.0436  -9.90 -9.81
#> 5 model1 forecast    variable2 2       -9.89  -9.82 0.158  -10.1  -9.79
#> 6 model1 forecast    variable2 3       -9.99  -9.82 0.360  -10.5  -9.79
```
