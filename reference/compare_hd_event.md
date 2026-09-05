# Compare historical-period shock contributions across model specifications

Compare historical-period shock contributions across model
specifications

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

  Probability mass of the equal-tailed credible intervals reported in
  posterior summaries.

- draws:

  If `TRUE`, report individual posterior draws rather than posterior
  summaries.

## Value

A `bsvar_post_tbl` combining event-window historical decomposition
results across models, with a `model` column identifying each model
specification.

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
#>   model object_type variable shock event_start event_end    mean  median    sd
#>   <chr> <chr>       <chr>    <chr> <chr>       <chr>       <dbl>   <dbl> <dbl>
#> 1 m1    hd_event    gdp      gdp   1948.25     1948.5     2.59    2.18   1.14 
#> 2 m1    hd_event    gs       gdp   1948.25     1948.5     2.98    3.41   1.70 
#> 3 m1    hd_event    ttr      gdp   1948.25     1948.5     0.0952  0.0767 0.158
#> 4 m1    hd_event    gdp      gs    1948.25     1948.5     0.572   0.559  0.298
#> 5 m1    hd_event    gs       gs    1948.25     1948.5    -4.00   -3.74   2.03 
#> 6 m1    hd_event    ttr      gs    1948.25     1948.5     0.0964  0.0278 0.164
#> # ℹ 2 more variables: lower <dbl>, upper <dbl>
```
