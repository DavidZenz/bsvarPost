# Compare half-life summaries across models

Compare half-life summaries across models

## Usage

``` r
compare_half_life_response(
  ...,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
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

- fraction:

  Fraction of the reference level used to define the half-life.

- baseline:

  Reference level: `"peak"` or `"initial"`.

- absolute:

  If `TRUE`, compute half-lives using absolute responses.

- probability:

  Equal-tailed interval probability.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` combining half-life summary results across models,
with a `model` column identifying each input.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_half_life_response(m1 = post1, m2 = post2, horizon = 3)
head(comp)
#> # A tibble: 6 × 12
#>   model object_type   variable shock fraction baseline mean_half_life
#>   <chr> <chr>         <chr>    <chr>    <dbl> <chr>             <dbl>
#> 1 m1    half_life_irf ttr      ttr        0.5 peak                 NA
#> 2 m1    half_life_irf ttr      gs         0.5 peak                 NA
#> 3 m1    half_life_irf ttr      gdp        0.5 peak                 NA
#> 4 m1    half_life_irf gs       ttr        0.5 peak                  3
#> 5 m1    half_life_irf gs       gs         0.5 peak                 NA
#> 6 m1    half_life_irf gs       gdp        0.5 peak                 NA
#> # ℹ 5 more variables: median_half_life <dbl>, sd_half_life <dbl>,
#> #   lower_half_life <dbl>, upper_half_life <dbl>, reached_prob <dbl>
```
