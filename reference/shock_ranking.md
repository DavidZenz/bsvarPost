# Ranks structural shocks by contributions over selected periods

Summarises posterior historical decompositions over a selected period
and ranks structural shocks by the absolute or signed magnitude of their
contributions.

## Usage

``` r
shock_ranking(
  object,
  start,
  end = start,
  variables = NULL,
  models = NULL,
  ranking = c("absolute", "signed"),
  probability = 0.9,
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorHD`, or a posterior-summary table
  of historical decompositions.

- start:

  First time index to include.

- end:

  Last time index to include. Defaults to `start`.

- variables:

  Variables whose historical decompositions are included.

- models:

  Model specifications to include.

- ranking:

  One of `"absolute"` or `"signed"`.

- probability:

  Probability mass of the equal-tailed credible interval.

- ...:

  Additional arguments passed to
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md).

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`shock`, `event_start`, `event_end`, `median`, `mean`, `sd`, `lower`,
`upper`, `ranking`, `rank_score`, and `rank`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

sr <- shock_ranking(post, start = "1948.25", end = "1948.5")
print(sr)
#> # A tibble: 9 × 24
#>   model  object_type   variable shock    mean   median    sd    lower  upper
#>   <chr>  <chr>         <chr>    <chr>   <dbl>    <dbl> <dbl>    <dbl>  <dbl>
#> 1 model1 shock_ranking ttr      ttr   -4.95   -4.52    5.32  -11.0     0.217
#> 2 model1 shock_ranking ttr      gdp    0.143   0.0262  0.416  -0.187   0.702
#> 3 model1 shock_ranking ttr      gs     0.0722 -0.00858 0.243  -0.0832  0.402
#> 4 model1 shock_ranking gs       gs    -1.21   -1.29    0.937  -2.25   -0.220
#> 5 model1 shock_ranking gs       gdp    0.474   0.0187  1.03   -0.0165  1.86 
#> 6 model1 shock_ranking gs       ttr    0.157   0.00902 0.412  -0.255   0.662
#> 7 model1 shock_ranking gdp      gdp   -0.766  -1.48    2.24   -3.05    2.04 
#> 8 model1 shock_ranking gdp      ttr   -3.21   -1.36    3.52   -7.99   -0.489
#> 9 model1 shock_ranking gdp      gs     0.730   0.0448  2.82   -1.60    4.44 
#> # ℹ 15 more variables: analysis_type <chr>, interval_probability <dbl>,
#> #   interval_method <chr>, scale_by <chr>, scale_var <chr>, scale_factor <dbl>,
#> #   units <chr>, source_package <chr>, source_version <chr>, n_draws <int>,
#> #   event_start <chr>, event_end <chr>, ranking <chr>, rank_score <dbl>,
#> #   rank <int>
```
