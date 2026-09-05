# Compare peak responses across model specifications

Compare peak responses across model specifications

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

  Response variables to include.

- shocks:

  Structural shocks to include.

- variable:

  Deprecated. Use `variables` instead.

- shock:

  Deprecated. Use `shocks` instead.

- absolute:

  If `TRUE`, search for the largest absolute response.

- probability:

  Probability mass of the equal-tailed credible interval.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` combining peak summary results across models, with a
`model` column identifying each model specification.

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
#> 1 m1    peak_irf    ttr      ttr     0.532         0.0823   0.984      0.0327  
#> 2 m1    peak_irf    ttr      gs      0.0434        0.0111   0.0825     0.000153
#> 3 m1    peak_irf    ttr      gdp     0.0126        0.00884  0.0155     0.000738
#> 4 m1    peak_irf    gs       ttr     0.308         0.0124   0.670     -0.000665
#> 5 m1    peak_irf    gs       gs      0.0576        0.0328   0.0585     0.0281  
#> 6 m1    peak_irf    gs       gdp     0.000469      0        0.00105    0       
#> # ℹ 6 more variables: upper_value <dbl>, mean_horizon <dbl>,
#> #   median_horizon <dbl>, sd_horizon <dbl>, lower_horizon <dbl>,
#> #   upper_horizon <dbl>
```
