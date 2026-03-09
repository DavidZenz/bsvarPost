# Simultaneous posterior bands for impulse responses

Construct simultaneous bands over a selected set of impulse responses
using the empirical sup-norm around the posterior median path.

## Usage

``` r
simultaneous_irf(object, ...)

# S3 method for class 'PosteriorIR'
simultaneous_irf(
  object,
  probability = 0.68,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
simultaneous_irf(
  object,
  horizon = 10,
  probability = 0.68,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
simultaneous_irf(
  object,
  horizon = 10,
  probability = 0.68,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
simultaneous_irf(
  object,
  horizon = 10,
  probability = 0.68,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSV'
simultaneous_irf(
  object,
  horizon = 10,
  probability = 0.68,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVART'
simultaneous_irf(
  object,
  horizon = 10,
  probability = 0.68,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
simultaneous_irf(
  object,
  horizon = 10,
  probability = 0.68,
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

  Coverage probability for the simultaneous band.

- variable:

  Optional response-variable subset.

- shock:

  Optional shock subset.

- model:

  Optional model identifier.

- horizon:

  Maximum horizon used when `object` is a posterior model object.
