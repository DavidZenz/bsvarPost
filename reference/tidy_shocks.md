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
#> 1 model1 shocks      ttr      1948.25 -2.56  -2.99  0.980 -3.11  -1.21  
#> 2 model1 shocks      ttr      1948.5  -1.47  -1.88  1.05  -2.13  -0.0456
#> 3 model1 shocks      ttr      1948.75 -0.337 -0.637 0.888 -0.954  0.857 
#> 4 model1 shocks      ttr      1949    -0.500 -0.783 0.888 -1.12   0.690 
#> 5 model1 shocks      ttr      1949.25 -0.806 -1.09  0.831 -1.38   0.315 
#> 6 model1 shocks      ttr      1949.5  -1.22  -1.54  0.940 -1.86   0.0493
```
