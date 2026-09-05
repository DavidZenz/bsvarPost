# Summarise posterior forecast error variance decompositions

Summarise posterior forecast error variance decompositions

## Usage

``` r
tidy_fevd(object, ...)

# Default S3 method
tidy_fevd(object, ...)
```

## Arguments

- object:

  A posterior model object or a `PosteriorFEVD` array.

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
#> 1 model1 fevd        ttr      ttr         0 100     100     0     1   e+2 100   
#> 2 model1 fevd        ttr      ttr         1  98.9    99.3   0.742 9.79e+1  99.5 
#> 3 model1 fevd        ttr      ttr         2  97.2    97.6   1.96  9.47e+1  99.0 
#> 4 model1 fevd        ttr      ttr         3  95.0    95.1   3.28  9.12e+1  98.6 
#> 5 model1 fevd        ttr      gs          0   0       0     0     0         0   
#> 6 model1 fevd        ttr      gs          1   0.511   0.248 0.577 5.45e-2   1.29
```
