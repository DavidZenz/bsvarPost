# Simultaneous posterior bands for cumulative dynamic multipliers

Simultaneous posterior bands for cumulative dynamic multipliers

## Usage

``` r
simultaneous_cdm(object, ...)

# S3 method for class 'PosteriorCDM'
simultaneous_cdm(
  object,
  probability = 0.68,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
simultaneous_cdm(
  object,
  horizon = 10,
  probability = 0.68,
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
  horizon = 10,
  probability = 0.68,
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
  horizon = 10,
  probability = 0.68,
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
  horizon = 10,
  probability = 0.68,
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
  horizon = 10,
  probability = 0.68,
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
  horizon = 10,
  probability = 0.68,
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

- variable:

  Optional response-variable subset.

- shock:

  Optional shock subset.

- model:

  Optional model identifier.

- horizon:

  Maximum horizon used when `object` is a posterior model object.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.
