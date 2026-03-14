# Rank shocks by event-window historical decomposition contributions

Rank shocks by event-window historical decomposition contributions

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

  A posterior model object, `PosteriorHD`, or tidy historical
  decomposition table.

- start:

  First time index to include.

- end:

  Last time index to include. Defaults to `start`.

- variables:

  Optional variable filter.

- models:

  Optional model filter.

- ranking:

  One of `"absolute"` or `"signed"`.

- probability:

  Equal-tailed interval probability.

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
#> # A tibble: 9 × 14
#>   model object_type variable shock event_start event_end    mean   median     sd
#>   <chr> <chr>       <chr>    <chr> <chr>       <chr>       <dbl>    <dbl>  <dbl>
#> 1 mode… hd_event    gdp      gdp   1948.25     1948.5     1.27    1.18    0.884 
#> 2 mode… hd_event    gdp      ttr   1948.25     1948.5     0.254   0.168   0.245 
#> 3 mode… hd_event    gdp      gs    1948.25     1948.5     0.0344  0.00353 0.0888
#> 4 mode… hd_event    gs       gs    1948.25     1948.5     0.654   0.391   0.679 
#> 5 mode… hd_event    gs       ttr   1948.25     1948.5    -0.0352 -0.00373 0.0821
#> 6 mode… hd_event    gs       gdp   1948.25     1948.5     0       0       0     
#> 7 mode… hd_event    ttr      ttr   1948.25     1948.5    -2.42   -2.52    1.27  
#> 8 mode… hd_event    ttr      gdp   1948.25     1948.5     0       0       0     
#> 9 mode… hd_event    ttr      gs    1948.25     1948.5     0       0       0     
#> # ℹ 5 more variables: lower <dbl>, upper <dbl>, ranking <chr>,
#> #   rank_score <dbl>, rank <int>
```
