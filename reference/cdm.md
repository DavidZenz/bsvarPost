# Cumulative Dynamic Multipliers

Compute cumulative dynamic multipliers (CDMs) for posterior objects from
`bsvars` and `bsvarSIGNs`.

## Usage

``` r
cdm(object, ...)

# S3 method for class 'PosteriorBSVAR'
cdm(
  object,
  horizon = 10,
  probability = 0.68,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
cdm(
  object,
  horizon = 10,
  probability = 0.68,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
cdm(
  object,
  horizon = 10,
  probability = 0.68,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
cdm(
  object,
  horizon = 10,
  probability = 0.68,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
cdm(
  object,
  horizon = 10,
  probability = 0.68,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
cdm(
  object,
  horizon = 10,
  probability = 0.68,
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

  Equal-tailed interval probability.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.
