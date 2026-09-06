# Evaluates magnitude hypotheses for impulse responses or cumulative multipliers

Computes posterior probabilities and summaries for magnitude conditions
on impulse responses or cumulative dynamic multipliers.

## Usage

``` r
magnitude_audit(
  object,
  type = c("irf", "cdm"),
  variable,
  shock,
  horizon,
  relation = c("<", "<=", ">", ">=", "=="),
  value = 0,
  compare_to = NULL,
  absolute = FALSE,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
```

## Arguments

- object:

  A posterior model object or response object.

- type:

  Posterior response quantity to evaluate.

- variable:

  **Deprecated.** Use `variables` instead.

- shock:

  **Deprecated.** Use `shocks` instead.

- horizon:

  Horizon selection on the left-hand side.

- relation:

  Comparison operator.

- value:

  Scalar comparison value for threshold statements.

- compare_to:

  Optional right-hand-side response specification with elements
  `variable`, `shock`, and `horizon`.

- absolute:

  If `TRUE`, compare absolute responses.

- probability:

  Probability mass of the equal-tailed credible interval for the
  posterior difference.

- draws:

  If `TRUE`, return draw-level gaps and indicators.

- model:

  Label identifying the model specification.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

- ...:

  Additional arguments passed to computation methods.

## Value

A `bsvar_post_tbl` with posterior hypothesis summaries including
`posterior_prob`, `mean`, `median`, `lower`, and `upper` columns.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

mag <- magnitude_audit(post, variable = "gdp", shock = "gdp",
                       horizon = 0, relation = ">")
#> Warning: In hypothesis_irf(): 'variable' is deprecated and will be removed in a future version.
#> Use 'variables' instead.
#> Warning: In hypothesis_irf(): 'shock' is deprecated and will be removed in a future version.
#> Use 'shocks' instead.
print(mag)
#> # A tibble: 1 × 17
#>   model  object_type variable shock horizon relation posterior_prob mean_gap
#>   <chr>  <chr>       <chr>    <chr>   <dbl> <chr>             <dbl>    <dbl>
#> 1 model1 irf         gdp      gdp         0 >                     1   0.0455
#> # ℹ 9 more variables: median_gap <dbl>, lower_gap <dbl>, upper_gap <dbl>,
#> #   rhs_variable <chr>, rhs_shock <chr>, rhs_horizon <dbl>, rhs_value <dbl>,
#> #   absolute <lgl>, audit_type <chr>
```
