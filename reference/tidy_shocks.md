# Tidy structural shocks

Tidy structural shocks

## Usage

``` r
tidy_shocks(object, ...)

# Default S3 method
tidy_shocks(object, ...)
```

## Arguments

- object:

  A posterior model object or posterior IRF array.

- ...:

  Additional arguments passed to computation methods.

## Value

A `bsvar_post_tbl` (tibble subclass) with columns `model`,
`object_type`, `variable`, `shock`, `time`, `mean`, `median`, `sd`,
`lower`, and `upper`. When `draws = TRUE`, columns `draw` and `value`
replace the summary statistics.

## Examples

``` r
# Small posterior (S = 5 draws)
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

# Tidy structural shocks
result <- tidy_shocks(post)
head(result)
#> # A tibble: 6 × 9
#>   model  object_type variable time      mean median    sd  lower   upper
#>   <chr>  <chr>       <chr>    <chr>    <dbl>  <dbl> <dbl>  <dbl>   <dbl>
#> 1 model1 shocks      ttr      1948.25 -1.83  -1.86  0.447 -2.29  -1.26  
#> 2 model1 shocks      ttr      1948.5  -0.401 -0.388 0.457 -0.972  0.0779
#> 3 model1 shocks      ttr      1948.75  0.740  0.903 0.321  0.296  0.949 
#> 4 model1 shocks      ttr      1949     0.657  0.755 0.387  0.132  0.955 
#> 5 model1 shocks      ttr      1949.25  0.421  0.426 0.476 -0.197  0.841 
#> 6 model1 shocks      ttr      1949.5   0.203  0.114 0.656 -0.611  0.830 
```
