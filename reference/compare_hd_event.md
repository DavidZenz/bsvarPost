# Compare event-window historical decompositions across models

Compare event-window historical decompositions across models

## Usage

``` r
compare_hd_event(..., start, end = start, probability = 0.9, draws = FALSE)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- start:

  First time index to include.

- end:

  Last time index to include. Defaults to `start`.

- probability:

  Equal-tailed interval probability used in summaries.

- draws:

  If `TRUE`, return draw-level rows.

## Value

A `bsvar_post_tbl` combining event-window historical decomposition
results across models, with a `model` column identifying each input.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_hd_event(m1 = post1, m2 = post2, start = "1948.25", end = "1948.5")
head(comp)
#> # A tibble: 6 × 11
#>   model object_type variable shock event_start event_end  mean median    sd
#>   <chr> <chr>       <chr>    <chr> <chr>       <chr>     <dbl>  <dbl> <dbl>
#> 1 m1    hd_event    gdp      gdp   1948.25     1948.5    0.827 1.32    1.58
#> 2 m1    hd_event    gs       gdp   1948.25     1948.5    0     0       0   
#> 3 m1    hd_event    ttr      gdp   1948.25     1948.5    0     0       0   
#> 4 m1    hd_event    gdp      gs    1948.25     1948.5    1.64  0.0651  2.24
#> 5 m1    hd_event    gs       gs    1948.25     1948.5    0.281 0.515   1.19
#> 6 m1    hd_event    ttr      gs    1948.25     1948.5    0     0       0   
#> # ℹ 2 more variables: lower <dbl>, upper <dbl>
```
