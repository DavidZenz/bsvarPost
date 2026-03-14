# Compare FEVDs across models

Compare FEVDs across models

## Usage

``` r
compare_fevd(..., horizon = NULL, probability = 0.9, draws = FALSE)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- horizon:

  Forecast horizon. If `NULL` (default), resolves to 20 periods.

- probability:

  Interval probability.

- draws:

  If `TRUE`, return draw-level rows.

## Value

A `bsvar_post_tbl` combining results across models, with a `model`
column identifying each input.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_fevd(m1 = post1, m2 = post2, horizon = 3)
head(comp)
#> # A tibble: 6 × 10
#>   model object_type variable shock horizon  mean   median    sd     lower upper
#>   <chr> <chr>       <chr>    <chr>   <dbl> <dbl>    <dbl> <dbl>     <dbl> <dbl>
#> 1 m1    fevd        ttr      ttr         0 100   100        0   100       100  
#> 2 m1    fevd        ttr      ttr         1  88.9  99.9     19.2  62.3     100.0
#> 3 m1    fevd        ttr      ttr         2  88.8  99.8     19.5  61.8     100.0
#> 4 m1    fevd        ttr      ttr         3  88.8  99.8     19.5  61.7      99.9
#> 5 m1    fevd        ttr      gs          0   0     0        0     0         0  
#> 6 m1    fevd        ttr      gs          1  10.3   0.0106  17.8   0.00151  34.9
```
