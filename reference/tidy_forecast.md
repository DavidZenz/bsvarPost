# Summarises draws from the predictive distribution

Transforms draws from the joint predictive distribution into a table
containing posterior predictive means, medians, standard deviations, and
equal-tailed intervals, or retains the individual draws when requested.

## Usage

``` r
tidy_forecast(object, ...)

# Default S3 method
tidy_forecast(object, ...)
```

## Arguments

- object:

  A posterior model object or a `Forecasts` object.

- ...:

  Additional arguments passed to computation methods.

## Value

A `bsvar_post_tbl` (tibble subclass) with columns `model`,
`object_type`, `variable`, `horizon`, `mean`, `median`, `sd`, `lower`,
and `upper`. When `draws = TRUE`, columns `draw` and `value` replace the
summary statistics.

## Examples

``` r
# Small posterior (S = 5 draws)
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

# Summaries of the predictive distribution
result <- tidy_forecast(post, horizon = 3)
head(result)
#> # A tibble: 6 × 19
#>   model  object_type variable horizon   mean median    sd  lower  upper
#>   <chr>  <chr>       <chr>      <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>
#> 1 model1 forecast    ttr            1  -8.70  -8.79 0.218  -8.88  -8.41
#> 2 model1 forecast    ttr            2  -8.73  -8.77 0.145  -8.86  -8.54
#> 3 model1 forecast    ttr            3  -8.50  -8.50 0.137  -8.62  -8.33
#> 4 model1 forecast    gs             1 -10.3  -10.1  0.612 -11.0   -9.71
#> 5 model1 forecast    gs             2 -10.2  -10.0  0.371 -10.7   -9.88
#> 6 model1 forecast    gs             3 -10.8  -10.9  0.482 -11.3  -10.2 
#> # ℹ 10 more variables: analysis_type <chr>, interval_probability <dbl>,
#> #   interval_method <chr>, scale_by <chr>, scale_var <chr>, scale_factor <dbl>,
#> #   units <chr>, source_package <chr>, source_version <chr>, n_draws <int>
```
