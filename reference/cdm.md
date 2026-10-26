# Computes posterior draws of cumulative dynamic multipliers

Each draw from the posterior distribution of the impulse responses is
transformed into a draw from the posterior distribution of cumulative
dynamic multipliers by summing responses from horizon zero onwards.

## Usage

``` r
cdm(object, ...)

# Default S3 method
cdm(object, ...)

# S3 method for class 'PosteriorBSVAR'
cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
```

## Arguments

- object:

  A posterior model object.

- ...:

  Additional arguments passed to methods.

- horizon:

  Forecast horizon.

- probability:

  Probability mass of the equal-tailed credible interval.

- scale_by:

  Either `"none"` or `"shock_sd"`. The latter divides each cumulative
  response by the selected observed variable's sample standard
  deviation, computed from the fitted sample.

- scale_var:

  Observed variable name or index used for `shock_sd` scaling; a scalar
  applies to every shock, or supply one entry per shock. With `NULL`,
  variables are matched to shocks by position.

## Value

A 4-dimensional array of class `PosteriorCDM` with dimensions
`[variables x shocks x (horizon + 1) x draws]`.

## Interpretation

The cumulative response at horizon `H` sums draw-level impulse responses
from zero through `H` (inclusive). Units follow the input
transformations and fitted structural-shock normalization. For log-level
data this is a cumulative log response, not a dollar-per-dollar fiscal
multiplier. `shock_sd` scaling does not form an output-to-spending
response ratio.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

cdm_draws <- cdm(post, horizon = 3)
dim(cdm_draws)
#> [1] 3 3 4 5
```
