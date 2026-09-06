# Compares posterior impulse responses across model specifications

Summarises impulse-response draws from two or more posterior model
objects in a common table identified by model specification.

## Usage

``` r
compare_irf(..., horizon = NULL, probability = 0.9, draws = FALSE)
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

comp <- compare_irf(m1 = post1, m2 = post2, horizon = 3)
head(comp)
#> # A tibble: 6 × 10
#>   model object_type variable shock horizon    mean   median     sd   lower
#>   <chr> <chr>       <chr>    <chr>   <dbl>   <dbl>    <dbl>  <dbl>   <dbl>
#> 1 m1    irf         ttr      ttr         0  0.105   0.0966  0.0178  0.0956
#> 2 m1    irf         ttr      ttr         1  0.101   0.123   0.0525  0.0304
#> 3 m1    irf         ttr      ttr         2  0.105   0.159   0.121  -0.0589
#> 4 m1    irf         ttr      ttr         3  0.116   0.206   0.193  -0.145 
#> 5 m1    irf         ttr      gs          0  0       0       0       0     
#> 6 m1    irf         ttr      gs          1 -0.0428 -0.00909 0.0718 -0.141 
#> # ℹ 1 more variable: upper <dbl>
```
