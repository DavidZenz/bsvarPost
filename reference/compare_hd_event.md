# Compares historical-period shock contributions across model specifications

Aggregates posterior draws of structural-shock contributions over a
selected historical period for two or more model specifications.

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
#> # A tibble: 6 × 21
#>   model object_type variable shock     mean  median      sd     lower   upper
#>   <chr> <chr>       <chr>    <chr>    <dbl>   <dbl>   <dbl>     <dbl>   <dbl>
#> 1 m1    hd_event    ttr      ttr   -12.1    -7.61    11.1   -27.2      -5.44 
#> 2 m1    hd_event    ttr      gs      0.0964  0.0278   0.164   0.00857   0.319
#> 3 m1    hd_event    ttr      gdp     0.0952  0.0767   0.158  -0.0498    0.300
#> 4 m1    hd_event    gs       ttr   120.     29.4    210.     18.9     402.   
#> 5 m1    hd_event    gs       gs     -4.00   -3.74     2.03   -6.71     -2.38 
#> 6 m1    hd_event    gs       gdp     2.98    3.41     1.70    0.681     4.13 
#> # ℹ 12 more variables: analysis_type <chr>, interval_probability <dbl>,
#> #   interval_method <chr>, scale_by <chr>, scale_var <chr>, scale_factor <dbl>,
#> #   units <chr>, source_package <chr>, source_version <chr>, n_draws <int>,
#> #   event_start <chr>, event_end <chr>
```
