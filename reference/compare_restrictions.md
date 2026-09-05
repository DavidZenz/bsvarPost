# Compare posterior restriction probabilities across model specifications

Compare posterior restriction probabilities across model specifications

## Usage

``` r
compare_restrictions(
  ...,
  restrictions = NULL,
  zero_tol = 1e-08,
  probability = 0.9
)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- restrictions:

  Optional list of restriction specifications evaluated for each model.

- zero_tol:

  Numerical tolerance for zero restrictions.

- probability:

  Probability mass of the equal-tailed credible intervals reported in
  posterior summaries.

## Value

A `bsvar_post_tbl` containing posterior restriction probabilities across
models, with a `model` column identifying each specification.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

r <- list(irf_restriction("gdp", "gdp", 0, sign = 1))
comp <- compare_restrictions(m1 = post1, m2 = post2, restrictions = r)
head(comp)
#> # A tibble: 2 × 12
#>   model restriction_type restriction      variable shock horizon relation
#>   <chr> <chr>            <chr>            <chr>    <chr>   <dbl> <chr>   
#> 1 m1    irf_sign         irf[gdp,gdp,0]>0 gdp      gdp         0 >0      
#> 2 m2    irf_sign         irf[gdp,gdp,0]>0 gdp      gdp         0 >0      
#> # ℹ 5 more variables: posterior_prob <dbl>, mean <dbl>, median <dbl>,
#> #   lower <dbl>, upper <dbl>
```
