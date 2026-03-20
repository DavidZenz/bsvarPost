# Tidy historical decompositions

Tidy historical decompositions

## Usage

``` r
tidy_hd(object, ...)

# Default S3 method
tidy_hd(object, ...)
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

# Tidy historical decompositions
result <- tidy_hd(post)
head(result)
#> # A tibble: 6 × 10
#>   model  object_type variable shock time     mean median    sd lower  upper
#>   <chr>  <chr>       <chr>    <chr> <chr>   <dbl>  <dbl> <dbl> <dbl>  <dbl>
#> 1 model1 hd          ttr      ttr   1948.25  0      0    0      0     0    
#> 2 model1 hd          ttr      ttr   1948.5  -1.55  -1.91 0.935 -2.05 -0.283
#> 3 model1 hd          ttr      ttr   1948.75 -2.23  -2.93 1.88  -3.31  0.306
#> 4 model1 hd          ttr      ttr   1949    -1.96  -2.87 2.71  -3.77  1.69 
#> 5 model1 hd          ttr      ttr   1949.25 -1.82  -2.95 3.57  -4.24  2.98 
#> 6 model1 hd          ttr      ttr   1949.5  -1.91  -3.44 4.48  -4.78  4.14 
```
