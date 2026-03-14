# Posterior probability statements for cumulative dynamic multipliers

Posterior probability statements for cumulative dynamic multipliers

## Usage

``` r
hypothesis_cdm(object, ...)

# Default S3 method
hypothesis_cdm(object, ...)

# S3 method for class 'PosteriorCDM'
hypothesis_cdm(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  horizon,
  relation = c("<", "<=", ">", ">=", "=="),
  value = 0,
  compare_to = NULL,
  absolute = FALSE,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
hypothesis_cdm(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
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

  A posterior model object or a `PosteriorIR` object.

- ...:

  Additional arguments passed to computation methods.

- variables:

  Response variable selection on the left-hand side (character or
  integer vector).

- shocks:

  Shock selection on the left-hand side (character or integer vector).

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

  Equal-tailed interval probability used for gap summaries.

- draws:

  If `TRUE`, return draw-level gaps and indicators.

- model:

  Optional model identifier.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`shock`, `horizon`, `relation`, `posterior_prob`, `mean_gap`,
`median_gap`, `lower_gap`, and `upper_gap`. When `draws = TRUE`, columns
`draw`, `gap`, and `satisfied` replace the summary statistics.
Additional columns `rhs_variable`, `rhs_shock`, `rhs_horizon`,
`rhs_value`, and `absolute` describe the right-hand side.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

h <- hypothesis_cdm(post, variable = "gdp", shock = "gdp",
                    horizon = 0:2, relation = ">", value = 0)
#> Warning: In hypothesis_cdm(): 'variable' is deprecated and will be removed in a future version.
#> Use 'variables' instead.
#> Warning: In hypothesis_cdm(): 'shock' is deprecated and will be removed in a future version.
#> Use 'shocks' instead.
print(h)
#> # A tibble: 3 × 16
#>   model  object_type variable shock horizon relation posterior_prob mean_gap
#>   <chr>  <chr>       <chr>    <chr>   <dbl> <chr>             <dbl>    <dbl>
#> 1 model1 cdm         gdp      gdp         0 >                     1   0.0189
#> 2 model1 cdm         gdp      gdp         1 >                     1   0.0371
#> 3 model1 cdm         gdp      gdp         2 >                     1   0.0543
#> # ℹ 8 more variables: median_gap <dbl>, lower_gap <dbl>, upper_gap <dbl>,
#> #   rhs_variable <chr>, rhs_shock <chr>, rhs_horizon <dbl>, rhs_value <dbl>,
#> #   absolute <lgl>
```
