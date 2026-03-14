# Compare cumulative dynamic multipliers across models

Compare cumulative dynamic multipliers across models

## Usage

``` r
compare_cdm(
  ...,
  horizon = NULL,
  probability = 0.9,
  draws = FALSE,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL
)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- horizon:

  Forecast horizon. If `NULL` (default), resolves to 20 periods.

- probability:

  Interval probability.

- draws:

  If `TRUE`, return draw-level rows.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` combining results across models, with a `model`
column identifying each input.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

comp <- compare_cdm(m1 = post1, m2 = post2, horizon = 3)
head(comp)
#> # A tibble: 6 × 10
#>   model object_type variable shock horizon     mean   median      sd   lower
#>   <chr> <chr>       <chr>    <chr>   <dbl>    <dbl>    <dbl>   <dbl>   <dbl>
#> 1 m1    cdm         ttr      ttr         0  0.0440  0.0404   0.0120   0.0336
#> 2 m1    cdm         ttr      ttr         1  0.0881  0.0790   0.0253   0.0676
#> 3 m1    cdm         ttr      ttr         2  0.133   0.117    0.0423   0.102 
#> 4 m1    cdm         ttr      ttr         3  0.181   0.156    0.0673   0.136 
#> 5 m1    cdm         ttr      gs          0  0       0        0        0     
#> 6 m1    cdm         ttr      gs          1 -0.00244 0.000759 0.00725 -0.0123
#> # ℹ 1 more variable: upper <dbl>
```
