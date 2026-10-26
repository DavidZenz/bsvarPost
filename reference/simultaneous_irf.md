# Computes simultaneous posterior bands for impulse responses

Transforms posterior draws of selected impulse responses into
simultaneous credible bands using the empirical sup-norm around the
posterior median response path. The empirical order statistic covers at
least the requested fraction of retained draws over the complete
selection. Ties can increase coverage. This is not a guarantee of exact
population posterior coverage. Boundaries are rounded outward when
necessary to retain the empirical guarantee in floating-point
arithmetic.

## Usage

``` r
simultaneous_irf(object, ...)

# Default S3 method
simultaneous_irf(object, ...)

# S3 method for class 'PosteriorIR'
simultaneous_irf(
  object,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSV'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVART'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object or a `PosteriorIR` object.

- ...:

  Additional arguments passed to computation methods.

- probability:

  Posterior coverage probability of the simultaneous credible band.

- variables:

  Response variables to include (character or integer vector).

- shocks:

  Structural shocks to include (character or integer vector).

- variable:

  **Deprecated.** Use `variables` instead.

- shock:

  **Deprecated.** Use `shocks` instead.

- model:

  Label identifying the model specification.

- horizon:

  Maximum horizon used when `object` is a posterior model object.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`shock`, `horizon`, `median`, `lower`, `upper`, `simultaneous_prob`,
`achieved_coverage`, and `critical_value`. Additional provenance columns
are described in
[posterior_provenance](https://davidzenz.github.io/bsvarPost/reference/posterior_provenance.md).

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

sb <- simultaneous_irf(post, horizon = 3)
head(sb)
#> # A tibble: 6 × 21
#>   model  object_type      variable shock horizon  median   lower  upper
#>   <chr>  <chr>            <chr>    <chr>   <dbl>   <dbl>   <dbl>  <dbl>
#> 1 model1 simultaneous_irf ttr      ttr         0  0.0561 -0.0892 0.201 
#> 2 model1 simultaneous_irf gs       ttr         0 -0.0523 -0.198  0.0930
#> 3 model1 simultaneous_irf gdp      ttr         0  0.0841 -0.0612 0.229 
#> 4 model1 simultaneous_irf ttr      gs          0  0      -0.145  0.145 
#> 5 model1 simultaneous_irf gs       gs          0  0.0432 -0.102  0.188 
#> 6 model1 simultaneous_irf gdp      gs          0 -0.0402 -0.185  0.105 
#> # ℹ 13 more variables: simultaneous_prob <dbl>, achieved_coverage <dbl>,
#> #   critical_value <dbl>, analysis_type <chr>, interval_probability <dbl>,
#> #   interval_method <chr>, scale_by <chr>, scale_var <chr>, scale_factor <dbl>,
#> #   units <chr>, source_package <chr>, source_version <chr>, n_draws <int>
```
