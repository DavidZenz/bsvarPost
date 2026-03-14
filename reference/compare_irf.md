# Compare posterior impulse responses across models

Compare posterior impulse responses across models

## Usage

``` r
compare_irf(..., horizon = NULL, probability = 0.9, draws = FALSE)
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

comp <- compare_irf(m1 = post1, m2 = post2, horizon = 3)
head(comp)
#> # A tibble: 6 × 10
#>   model object_type variable shock horizon     mean   median      sd     lower
#>   <chr> <chr>       <chr>    <chr>   <dbl>    <dbl>    <dbl>   <dbl>     <dbl>
#> 1 m1    irf         ttr      ttr         0 0.0406   0.0312   0.0201   0.0296  
#> 2 m1    irf         ttr      ttr         1 0.0356   0.0310   0.0119   0.0269  
#> 3 m1    irf         ttr      ttr         2 0.0318   0.0309   0.00705  0.0244  
#> 4 m1    irf         ttr      ttr         3 0.0287   0.0308   0.00522  0.0221  
#> 5 m1    irf         ttr      gs          0 0        0        0        0       
#> 6 m1    irf         ttr      gs          1 0.000625 0.000339 0.00148 -0.000775
#> # ℹ 1 more variable: upper <dbl>
```
