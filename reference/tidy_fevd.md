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
#>   model  object_type variable shock horizon    mean  median    sd   lower  upper
#>   <chr>  <chr>       <chr>    <chr>   <dbl>   <dbl>   <dbl> <dbl>   <dbl>  <dbl>
#> 1 model1 fevd        ttr      ttr         0 100     1   e+2 0     1   e+2 100   
#> 2 model1 fevd        ttr      ttr         1  98.2   9.83e+1 1.44  9.66e+1  99.7 
#> 3 model1 fevd        ttr      ttr         2  94.5   9.28e+1 3.82  9.09e+1  98.9 
#> 4 model1 fevd        ttr      ttr         3  89.2   8.81e+1 7.69  8.19e+1  97.8 
#> 5 model1 fevd        ttr      gs          0   0     0       0     0         0   
#> 6 model1 fevd        ttr      gs          1   0.444 2.10e-3 0.943 6.56e-4   1.72
```
