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
#>   model  object_type variable shock horizon    mean  median     sd   lower
#>   <chr>  <chr>       <chr>    <chr>   <dbl>   <dbl>   <dbl>  <dbl>   <dbl>
#> 1 model1 fevd        ttr      ttr         0 100     100      0     100    
#> 2 model1 fevd        ttr      ttr         1  98.3    98.1    0.924  97.2  
#> 3 model1 fevd        ttr      ttr         2  92.7    90.8    4.05   88.7  
#> 4 model1 fevd        ttr      ttr         3  80.5    74.3   10.2    72.9  
#> 5 model1 fevd        ttr      gs          0   0       0      0       0    
#> 6 model1 fevd        ttr      gs          1   0.370   0.265  0.263   0.192
#> # ℹ 1 more variable: upper <dbl>
```
