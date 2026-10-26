# Computes simultaneous posterior bands for cumulative dynamic multipliers

Transforms posterior draws of selected cumulative dynamic multipliers
into simultaneous credible bands using the empirical sup-norm around the
posterior median response path. The empirical order statistic covers at
least the requested fraction of retained draws; ties can increase
coverage.

## Usage

``` r
simultaneous_cdm(object, ...)

# Default S3 method
simultaneous_cdm(object, ...)

# S3 method for class 'PosteriorCDM'
simultaneous_cdm(
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
simultaneous_cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
simultaneous_cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
simultaneous_cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
simultaneous_cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
simultaneous_cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
simultaneous_cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
```

## Arguments

- object:

  A posterior model object or a `PosteriorCDM` array.

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

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

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

sb <- simultaneous_cdm(post, horizon = 3)
head(sb)
#> # A tibble: 6 × 21
#>   model object_type variable shock horizon  median lower upper simultaneous_prob
#>   <chr> <chr>       <chr>    <chr>   <dbl>   <dbl> <dbl> <dbl>             <dbl>
#> 1 mode… simultaneo… ttr      ttr         0  0.636  -1.46  2.73               0.9
#> 2 mode… simultaneo… gs       ttr         0 -0.319  -2.41  1.77               0.9
#> 3 mode… simultaneo… gdp      ttr         0 -0.205  -2.30  1.89               0.9
#> 4 mode… simultaneo… ttr      gs          0  0      -2.09  2.09               0.9
#> 5 mode… simultaneo… gs       gs          0  0.0330 -2.06  2.13               0.9
#> 6 mode… simultaneo… gdp      gs          0  0.0342 -2.06  2.13               0.9
#> # ℹ 12 more variables: achieved_coverage <dbl>, critical_value <dbl>,
#> #   analysis_type <chr>, interval_probability <dbl>, interval_method <chr>,
#> #   scale_by <chr>, scale_var <chr>, scale_factor <dbl>, units <chr>,
#> #   source_package <chr>, source_version <chr>, n_draws <int>
```
