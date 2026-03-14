# Tidy forecast error variance decompositions

Tidy forecast error variance decompositions

## Usage

``` r
tidy_fevd(object, ...)

# Default S3 method
tidy_fevd(object, ...)
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

# Tidy forecast error variance decompositions
result <- tidy_fevd(post, horizon = 3)
head(result)
#> # A tibble: 6 × 10
#>   model object_type variable shock horizon    mean  median     sd   lower  upper
#>   <chr> <chr>       <chr>    <chr>   <dbl>   <dbl>   <dbl>  <dbl>   <dbl>  <dbl>
#> 1 mode… fevd        ttr      ttr         0 100     100      0     100     100   
#> 2 mode… fevd        ttr      ttr         1  97.0    98.1    2.84   93.1    98.9 
#> 3 mode… fevd        ttr      ttr         2  89.4    93.9   11.4    73.8    96.6 
#> 4 mode… fevd        ttr      ttr         3  79.3    88.1   22.5    48.6    93.0 
#> 5 mode… fevd        ttr      gs          0   0       0      0       0       0   
#> 6 mode… fevd        ttr      gs          1   0.892   0.792  0.551   0.390   1.62
```
