# Compares cumulative dynamic multipliers across model specifications

Summarises posterior draws of cumulative dynamic multipliers from two or
more model objects in a common table identified by model specification.

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

  Probability mass of the equal-tailed credible interval.

- draws:

  If `TRUE`, report individual posterior draws rather than posterior
  summaries.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` combining results across models, with a `model`
column identifying each model specification.

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
#>   model object_type variable shock horizon    mean  median     sd      lower
#>   <chr> <chr>       <chr>    <chr>   <dbl>   <dbl>   <dbl>  <dbl>      <dbl>
#> 1 m1    cdm         ttr      ttr         0  0.0424 0.0295  0.0296   0.0283  
#> 2 m1    cdm         ttr      ttr         1 -0.671  0.0542  1.62    -2.85    
#> 3 m1    cdm         ttr      ttr         2 -1.78   0.0777  4.16    -7.36    
#> 4 m1    cdm         ttr      ttr         3 -2.92   0.0920  6.74   -12.0     
#> 5 m1    cdm         ttr      gs          0  0      0       0        0       
#> 6 m1    cdm         ttr      gs          1  0.753  0.00191 1.68    -0.000456
#> # ℹ 1 more variable: upper <dbl>
```
