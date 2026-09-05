# Evaluate sign, zero, structural, and narrative restrictions

Evaluate sign, zero, structural, and narrative restrictions

## Usage

``` r
restriction_audit(
  object,
  restrictions = NULL,
  zero_tol = 1e-08,
  probability = 0.9,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object.

- restrictions:

  Optional list of restriction specifications. If omitted for
  `PosteriorBSVARSIGN`, restrictions are extracted from the fitted
  identification scheme.

- zero_tol:

  Numerical tolerance for zero restrictions.

- probability:

  Probability mass of the equal-tailed credible intervals reported in
  posterior summaries.

- model:

  Label identifying the model specification.

- ...:

  Reserved for future extensions.

## Value

A `bsvar_post_tbl` with columns `model`, `restriction_type`,
`restriction`, `variable`, `shock`, `horizon`, `relation`,
`posterior_prob`, `mean`, `median`, `lower`, and `upper`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

r <- list(irf_restriction("gdp", "gdp", 0, sign = 1))
audit <- restriction_audit(post, restrictions = r)
print(audit)
#> # A tibble: 1 × 12
#>   model  restriction_type restriction      variable shock horizon relation
#>   <chr>  <chr>            <chr>            <chr>    <chr>   <dbl> <chr>   
#> 1 model1 irf_sign         irf[gdp,gdp,0]>0 gdp      gdp         0 >0      
#> # ℹ 5 more variables: posterior_prob <dbl>, mean <dbl>, median <dbl>,
#> #   lower <dbl>, upper <dbl>
```
