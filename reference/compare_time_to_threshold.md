# Compare time-to-threshold summaries across models

Compare time-to-threshold summaries across models

## Usage

``` r
compare_time_to_threshold(
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

- probability:

  Equal-tailed interval probability.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` combining time-to-threshold summary results across
models, with a `model` column identifying each input.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_time_to_threshold(m1 = post1, m2 = post2, horizon = 3,
                                   relation = ">", value = 0)
head(comp)
#> # A tibble: 6 × 12
#>   model object_type           variable shock relation threshold mean_horizon
#>   <chr> <chr>                 <chr>    <chr> <chr>        <dbl>        <dbl>
#> 1 m1    time_to_threshold_irf ttr      ttr   >                0            0
#> 2 m1    time_to_threshold_irf ttr      gs    >                0           NA
#> 3 m1    time_to_threshold_irf ttr      gdp   >                0            1
#> 4 m1    time_to_threshold_irf gs       ttr   >                0            2
#> 5 m1    time_to_threshold_irf gs       gs    >                0            0
#> 6 m1    time_to_threshold_irf gs       gdp   >                0           NA
#> # ℹ 5 more variables: median_horizon <dbl>, sd_horizon <dbl>,
#> #   lower_horizon <dbl>, upper_horizon <dbl>, reached_prob <dbl>
```
