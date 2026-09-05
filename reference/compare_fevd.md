# Compare forecast error variance decompositions across model specifications

Compare forecast error variance decompositions across model
specifications

## Usage

``` r
compare_fevd(..., horizon = NULL, probability = 0.9, draws = FALSE)
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

comp <- compare_fevd(m1 = post1, m2 = post2, horizon = 3)
head(comp)
#> # A tibble: 6 × 10
#>   model object_type variable shock horizon   mean median    sd  lower  upper
#>   <chr> <chr>       <chr>    <chr>   <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>
#> 1 m1    fevd        ttr      ttr         0 100    100     0    100    100   
#> 2 m1    fevd        ttr      ttr         1  77.0   73.4   7.24  72.3   87.0 
#> 3 m1    fevd        ttr      ttr         2  58.5   54.8   7.34  53.5   68.7 
#> 4 m1    fevd        ttr      ttr         3  46.2   45.7   3.08  43.1   50.2 
#> 5 m1    fevd        ttr      gs          0   0      0     0      0      0   
#> 6 m1    fevd        ttr      gs          1   5.60   5.45  2.63   2.38   8.37
```
