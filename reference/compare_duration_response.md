# Compare duration summaries across models

Compare duration summaries across models

## Usage

``` r
compare_duration_response(
  ...,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  mode = c("consecutive", "total"),
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

- relation:

  Comparison operator.

- value:

  Threshold value.

- absolute:

  If `TRUE`, compare absolute responses.

- mode:

  Either `"consecutive"` or `"total"`.

- probability:

  Equal-tailed interval probability.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` combining duration summary results across models,
with a `model` column identifying each input.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_duration_response(m1 = post1, m2 = post2, horizon = 3,
                                   relation = ">", value = 0)
head(comp)
#> # A tibble: 6 × 12
#>   model object_type  variable shock relation threshold mode        mean_duration
#>   <chr> <chr>        <chr>    <chr> <chr>        <dbl> <chr>               <dbl>
#> 1 m1    duration_irf ttr      ttr   >                0 consecutive           4  
#> 2 m1    duration_irf ttr      gs    >                0 consecutive           0  
#> 3 m1    duration_irf ttr      gdp   >                0 consecutive           0  
#> 4 m1    duration_irf gs       ttr   >                0 consecutive           0.6
#> 5 m1    duration_irf gs       gs    >                0 consecutive           4  
#> 6 m1    duration_irf gs       gdp   >                0 consecutive           0  
#> # ℹ 4 more variables: median_duration <dbl>, sd_duration <dbl>,
#> #   lower_duration <dbl>, upper_duration <dbl>
```
