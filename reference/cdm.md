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

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A 4-dimensional array of class `PosteriorCDM` with dimensions
`[variables x shocks x (horizon + 1) x draws]`.

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
