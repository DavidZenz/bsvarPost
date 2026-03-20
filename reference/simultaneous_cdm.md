# Simultaneous posterior bands for cumulative dynamic multipliers

Simultaneous posterior bands for cumulative dynamic multipliers

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

  A posterior model object or a `PosteriorIR` object.

- ...:

  Additional arguments passed to computation methods.

- probability:

  Coverage probability for the simultaneous band.

- variables:

  Optional response-variable subset (character or integer vector).

- shocks:

  Optional shock subset (character or integer vector).

- variable:

  **Deprecated.** Use `variables` instead.

- shock:

  **Deprecated.** Use `shocks` instead.

- model:

  Optional model identifier.

- horizon:

  Maximum horizon used when `object` is a posterior model object.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`shock`, `horizon`, `median`, `lower`, `upper`, `simultaneous_prob`, and
`critical_value`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

sb <- simultaneous_cdm(post, horizon = 3)
head(sb)
#> # A tibble: 6 × 10
#>   model object_type variable shock horizon median  lower upper simultaneous_prob
#>   <chr> <chr>       <chr>    <chr>   <dbl>  <dbl>  <dbl> <dbl>             <dbl>
#> 1 mode… simultaneo… ttr      ttr         0 0.0441 -0.204 0.292               0.9
#> 2 mode… simultaneo… gs       ttr         0 0.0371 -0.211 0.285               0.9
#> 3 mode… simultaneo… gdp      ttr         0 0.0359 -0.212 0.284               0.9
#> 4 mode… simultaneo… ttr      gs          0 0      -0.248 0.248               0.9
#> 5 mode… simultaneo… gs       gs          0 0.0586 -0.190 0.307               0.9
#> 6 mode… simultaneo… gdp      gs          0 0.0309 -0.217 0.279               0.9
#> # ℹ 1 more variable: critical_value <dbl>
```
