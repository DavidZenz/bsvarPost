# Compare peak response summaries across models

Compare peak response summaries across models

## Usage

``` r
compare_peak_response(
  ...,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.9,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL
)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- horizon:

  Maximum horizon used when `object` is a posterior model object. If
  `NULL` (default), resolves to 20 periods.

- type:

  Response type for posterior model objects: `"irf"` or `"cdm"`.

- variables:

  Optional response-variable subset.

- shocks:

  Optional shock subset.

- variable:

  Deprecated. Use `variables` instead.

- shock:

  Deprecated. Use `shocks` instead.

- absolute:

  If `TRUE`, search for the largest absolute response.

- probability:

  Equal-tailed interval probability.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` combining peak summary results across models, with a
`model` column identifying each input.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_peak_response(m1 = post1, m2 = post2, horizon = 3)
head(comp)
#> # A tibble: 6 × 14
#>   model object_type variable shock mean_value median_value sd_value lower_value
#>   <chr> <chr>       <chr>    <chr>      <dbl>        <dbl>    <dbl>       <dbl>
#> 1 m1    peak_irf    ttr      ttr      0.0459      0.0346    0.0278      0.0313 
#> 2 m1    peak_irf    ttr      gs       0           0         0           0      
#> 3 m1    peak_irf    ttr      gdp      0.0211      0.00933   0.0228      0.00233
#> 4 m1    peak_irf    gs       ttr     -0.00394    -0.00232   0.00332    -0.00852
#> 5 m1    peak_irf    gs       gs       0.0336      0.0291    0.0135      0.0249 
#> 6 m1    peak_irf    gs       gdp      0.00462     0.000737  0.00894     0      
#> # ℹ 6 more variables: upper_value <dbl>, mean_horizon <dbl>,
#> #   median_horizon <dbl>, sd_horizon <dbl>, lower_horizon <dbl>,
#> #   upper_horizon <dbl>
```
